package auth

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"toyhouse_api/v2/lib/scraper"
	"toyhouse_api/v2/lib/structs"

	"github.com/PuerkitoBio/goquery"
	"github.com/spf13/viper"
)

// LoadInitialAuth loads authentication cookies from environment variables
// and sets them in the cookie jar. The cookie jar will automatically
// update cookies from server responses.
func LoadInitialAuth(client *http.Client) {
	if(flag.Lookup("test.v") == nil ) {
		viper.SetConfigFile(".env")
	} else {
		viper.SetConfigFile("../../etc/secrets/.env")
	}

	viper.ReadInConfig();
	viper.AutomaticEnv();

	// Read cookies from environment variables
	cfClearanceRaw, ok := viper.Get("CF_CLEARANCE").(string);
	if !ok || cfClearanceRaw == "" {
		log.Fatal("CF_CLEARANCE environment variable is required!");
	}
	cfClearance, err := url.QueryUnescape(cfClearanceRaw);
	if err != nil {
		log.Fatal("Failed to decode CF_CLEARANCE:", err);
	}

	laravelSessionRaw, ok := viper.Get("LARAVEL_SESSION").(string);
	if !ok || laravelSessionRaw == "" {
		log.Fatal("LARAVEL_SESSION environment variable is required!");
	}
	laravelSession, err := url.QueryUnescape(laravelSessionRaw);
	if err != nil {
		log.Fatal("Failed to decode LARAVEL_SESSION:", err);
	}

	rememberCookieRaw, ok := viper.Get("REMEMBER_COOKIE").(string);
	if !ok || rememberCookieRaw == "" {
		log.Fatal("REMEMBER_COOKIE environment variable is required!");
	}
	rememberCookie, err := url.QueryUnescape(rememberCookieRaw);
	if err != nil {
		log.Fatal("Failed to decode REMEMBER_COOKIE:", err);
	}

	xsrfTokenRaw, ok := viper.Get("XSRF_TOKEN").(string);
	if !ok || xsrfTokenRaw == "" {
		log.Fatal("XSRF_TOKEN environment variable is required!");
	}
	xsrfToken, err := url.QueryUnescape(xsrfTokenRaw);
	if err != nil {
		log.Fatal("Failed to decode XSRF_TOKEN:", err);
	}

	// Parse the base URL
	baseURL, err := url.Parse("https://toyhou.se");
	if err != nil {
		log.Fatal("Failed to parse base URL:", err);
	}

	// Create cookies and add them to the jar
	cookies := []*http.Cookie{
		{
			Name:   "CF_CLEARANCE",
			Value:  cfClearance,
			Domain: ".toyhou.se",
			Path:   "/",
		},
		{
			Name:   "laravel_session",
			Value:  laravelSession,
			Domain: ".toyhou.se",
			Path:   "/",
		},
		{
			Name:   "remember_web_59ba36addc2b2f9401580f014c7f58ea4e30989d",
			Value:  rememberCookie,
			Domain: ".toyhou.se",
			Path:   "/",
		},
		{
			Name:   "XSRF-TOKEN",
			Value:  xsrfToken,
			Domain: ".toyhou.se",
			Path:   "/",
		},
	}

	// Set cookies in the jar
	if client.Jar != nil {
		client.Jar.SetCookies(baseURL, cookies);
		fmt.Println("Successfully loaded authentication cookies from environment variables");
	} else {
		log.Fatal("Client does not have a cookie jar!");
	}

	// Test authentication by making a request and printing the response
	fmt.Println("Testing authentication by fetching https://toyhou.se/~account/authorizers");
	testRes, err := client.Get("https://toyhou.se/~account/authorizers");
	if err != nil {
		log.Fatal("Failed to make test request:", err);
	}
	defer testRes.Body.Close();

	bodyBytes, err := io.ReadAll(testRes.Body);
	if err != nil {
		log.Fatal("Failed to read test response body:", err);
	}

	fmt.Println("=== Response Status ===");
	fmt.Printf("Status Code: %d\n", testRes.StatusCode);
	fmt.Printf("Status: %s\n", testRes.Status);
	fmt.Println("\n=== Response Headers ===");
	for key, values := range testRes.Header {
		for _, value := range values {
			fmt.Printf("%s: %s\n", key, value);
		}
	}
	fmt.Println("\n=== Response Body (first 2000 chars) ===");
	bodyString := string(bodyBytes);
	if len(bodyString) > 2000 {
		fmt.Println(bodyString[:2000]);
		fmt.Println("... (truncated)");
	} else {
		fmt.Println(bodyString);
	}
	fmt.Println("\n=== End of Response ===");
}

func GetAuthorizedUsers(client *http.Client) []string {
	get_usernames := func(doc *goquery.Document) []string {
		var usernames []string;
		doc.Find("a.user-name-badge").Each(func(i int, ele *goquery.Selection) {
			username := ele.Text();
			usernames = append(usernames, username);
		});

		return usernames
	}

	all_usernames, _ := scraper.SaveWithPagination(client, "https://toyhou.se/~account/authorizers", get_usernames)

	return all_usernames;
}

func EnsureUserHasAccess(char *structs.Character) (bool, error) {
	viper.AutomaticEnv();

	username, ok := viper.Get("TOYHOUSE_USERNAME") . (string);
	
	if !ok {
		log.Fatal("Error while reading username!");
	}

	if username == char.Owner.Name {
		return true, nil;
	}

	return false, errors.New("User does not have access");
}