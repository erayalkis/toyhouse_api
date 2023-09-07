package auth

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"strings"
	"toyhouse_api/v2/lib/scraper"
	"toyhouse_api/v2/lib/structs"

	"github.com/PuerkitoBio/goquery"
	"github.com/spf13/viper"
)

// Make request to /login, keep all the cookies
// I'm guessing the auth cookie should refresh if we have all the necessary cookies, since you never really have to login again when using the site normally even if a long time passes between each use.
// !! Definitely play around with this !!

// Update: Wow, was I high? Of course the cookie refreshes
func LoadInitialAuth(client *http.Client) {
	page, err := client.Get("https://toyhou.se/~account/login");
	if err != nil {
		log.Fatal(err);
	}

	if(flag.Lookup("test.v") == nil ) {
		viper.SetConfigFile(".env")
	} else {
		viper.SetConfigFile("../../etc/secrets/.env")
	}

	viper.ReadInConfig();
	viper.AutomaticEnv();

	username, ok := viper.Get("TOYHOUSE_USERNAME") . (string);
	fmt.Printf("username: %v\n", username)
	if !ok {
		log.Fatal("Something went wrong while reading username!");
	}
	password, ok := viper.Get("TOYHOUSE_PASSWORD") . (string);
	fmt.Printf("password: %v\n", password)
	if !ok {
		log.Fatal("Something went wrong while reading password!");
	}

	doc, err := goquery.NewDocumentFromReader(page.Body);

	if err != nil {
		log.Fatal(err);
	}

	csrf_token, ok := doc.Find("meta[name='csrf-token']").Attr("content");

	if !ok {
		log.Fatal("Something went wrong while reading csrf token element!");
	}


	form_data := url.Values{
		"username": { username },
		"password": { password },
		"_token": { csrf_token },
	}

	println("Posting login form with data:", form_data.Encode());
	res, err := client.PostForm("https://toyhou.se/~account/login", form_data);
	if err != nil {
		log.Fatal(err)
	}

	defer res.Body.Close()

	bodyBytes, err := io.ReadAll(res.Body)
	if err != nil {
		log.Fatal(err)
	}

	bodyString := string(bodyBytes)

	stillOnLoginPage := strings.Contains(bodyString, "Login")

	if stillOnLoginPage {
		log.Fatal("Login unsuccesful! Please check that you have the correct username/password!");
	}
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

func EnsureUserHasAccess(char *structs.Character, auths []string) (bool, error) {
	for _, username := range auths {
		if username == char.Owner.Name {
			return true, nil;
		}
	}

	return false, errors.New("Username not in auths array");
}