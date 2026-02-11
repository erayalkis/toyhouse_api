package browser

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	"github.com/go-rod/rod"
	"github.com/go-rod/rod/lib/launcher"
	"github.com/go-rod/rod/lib/proto"
)

var browserInstance *rod.Browser

// InitBrowser initializes a headless browser instance
func InitBrowser() {
	// Check for custom Chromium path (useful for Docker)
	launchOptions := launcher.New().
		Headless(true).
		Set("disable-blink-features", "AutomationControlled").
		Set("disable-dev-shm-usage").
		Set("no-sandbox").
		Set("disable-setuid-sandbox").
		Set("disable-gpu").
		UserDataDir("")
	
	// Use custom Chromium path if set (for Docker)
	if chromiumPath := os.Getenv("CHROMIUM_PATH"); chromiumPath != "" {
		launchOptions = launchOptions.Bin(chromiumPath)
		fmt.Printf("Using Chromium at: %s\n", chromiumPath)
	} else if chromePath := os.Getenv("CHROME_PATH"); chromePath != "" {
		launchOptions = launchOptions.Bin(chromePath)
		fmt.Printf("Using Chrome at: %s\n", chromePath)
	}

	l := launchOptions.MustLaunch()

	browserInstance = rod.New().ControlURL(l).MustConnect()
	
	// Set stealth settings
	browserInstance.MustIgnoreCertErrors(true)

	fmt.Println("Headless browser initialized")
}

// FetchWithBrowser fetches a URL using headless browser and returns the HTML content
// It syncs cookies from the HTTP client's cookie jar and updates them back after the request
func FetchWithBrowser(targetURL string, client *http.Client) (string, error) {
	if browserInstance == nil {
		return "", fmt.Errorf("browser not initialized")
	}

	// Create a new page for this request
	page := browserInstance.MustPage()
	defer page.Close()

	// Enable JavaScript execution
	page.MustEval(`() => { window.navigator.webdriver = undefined; }`)

	// Set user agent to avoid detection
	page.MustSetUserAgent(&proto.NetworkSetUserAgentOverride{
		UserAgent:      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
		AcceptLanguage: "en-US,en;q=0.9",
		Platform:       "Linux x86_64",
	})

	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	// Parse URL
	parsedURL, err := url.Parse(targetURL)
	if err != nil {
		return "", fmt.Errorf("failed to parse URL: %w", err)
	}

	// Get base domain URL for cookie setting
	baseURL := fmt.Sprintf("%s://%s", parsedURL.Scheme, parsedURL.Host)
	baseParsedURL, _ := url.Parse(baseURL)

	// Get cookies from HTTP client's cookie jar (try both specific URL and base domain)
	var rodCookies []*proto.NetworkCookieParam
	if client.Jar != nil {
		// Get cookies for the specific URL
		httpCookies := client.Jar.Cookies(parsedURL)
		// Also get cookies for base domain
		if parsedURL.Host != baseParsedURL.Host {
			baseCookies := client.Jar.Cookies(baseParsedURL)
			httpCookies = append(httpCookies, baseCookies...)
		}
		
		for _, cookie := range httpCookies {
			// Use base domain for cookie domain if it's a domain cookie
			cookieDomain := cookie.Domain
			if cookieDomain == "" {
				cookieDomain = parsedURL.Host
			}
			
			rodCookies = append(rodCookies, &proto.NetworkCookieParam{
				Name:   cookie.Name,
				Value:  cookie.Value,
				Domain: cookieDomain,
				Path:   cookie.Path,
			})
		}
		fmt.Printf("Setting %d cookies in browser\n", len(rodCookies))
	}

	// Navigate to base domain first to establish session (if we have cookies)
	if len(rodCookies) > 0 {
		fmt.Println("Navigating to base domain first:", baseURL)
		err = page.Context(ctx).Navigate(baseURL)
		if err == nil {
			page.WaitLoad()
			
			// Set cookies after initial navigation
			err = page.SetCookies(rodCookies)
			if err != nil {
				log.Printf("Warning: Failed to set cookies: %v", err)
			} else {
				fmt.Println("Cookies set successfully")
			}
			
			// Reload to apply cookies
			page.MustReload()
			page.WaitLoad()
		}
	}

	// Navigate to the target page
	fmt.Println("Navigating to target URL:", targetURL)
	err = page.Context(ctx).Navigate(targetURL)
	if err != nil {
		return "", fmt.Errorf("failed to navigate: %w", err)
	}

	// Wait for the page to load
	err = page.WaitLoad()
	if err != nil {
		return "", fmt.Errorf("failed to wait for page load: %w", err)
	}

	// Wait for JavaScript to execute and Cloudflare challenge to complete
	maxWait := 20 * time.Second
	checkInterval := 500 * time.Millisecond
	elapsed := time.Duration(0)
	
	fmt.Println("Waiting for Cloudflare challenge to complete...")
	for elapsed < maxWait {
		// Check page title and HTML content
		title, _ := page.Eval(`() => document.title`)
		html, _ := page.HTML()
		
		titleStr := ""
		if title != nil {
			titleStr = title.Value.String()
		}
		
		// Check if we're past the Cloudflare challenge
		isChallenge := strings.Contains(html, "Just a moment") || 
		               strings.Contains(html, "challenge-platform") ||
		               strings.Contains(html, "Enable JavaScript and cookies") ||
		               strings.Contains(titleStr, "Just a moment")
		
		if !isChallenge {
			fmt.Printf("Cloudflare challenge passed! Title: %s\n", titleStr)
			break
		}
		
		time.Sleep(checkInterval)
		elapsed += checkInterval
		if int(elapsed.Seconds())%2 == 0 {
			fmt.Printf("Still waiting... (%.1fs) Title: %s\n", elapsed.Seconds(), titleStr)
		}
	}
	
	// Final check - if still on challenge page, log warning
	finalHTML, _ := page.HTML()
	if strings.Contains(finalHTML, "Just a moment") {
		fmt.Println("WARNING: Still on Cloudflare challenge page after waiting!")
		fmt.Printf("Page HTML preview: %s\n", finalHTML[:500])
	}

	// Get cookies from browser and sync back to HTTP client
	if client.Jar != nil {
		browserCookies, err := page.Cookies([]string{targetURL})
		if err == nil {
			for _, cookie := range browserCookies {
				httpCookie := &http.Cookie{
					Name:   cookie.Name,
					Value:  cookie.Value,
					Domain: cookie.Domain,
					Path:   cookie.Path,
				}
				client.Jar.SetCookies(parsedURL, []*http.Cookie{httpCookie})
			}
		}
	}

	// Get the HTML content
	html, err := page.HTML()
	if err != nil {
		return "", fmt.Errorf("failed to get HTML: %w", err)
	}

	return html, nil
}

// CloseBrowser closes the browser instance
func CloseBrowser() {
	if browserInstance != nil {
		browserInstance.Close()
	}
}

