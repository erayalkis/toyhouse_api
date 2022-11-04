package auth

import (
	"errors"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"toyhouse_api/v2/lib/scraper"
	"toyhouse_api/v2/lib/structs"

	"github.com/PuerkitoBio/goquery"
	"github.com/spf13/viper"
)

// Make request to /login, keep all the cookies
// I'm guessing the auth cookie should refresh if we have all the necessary cookies, since you never really have to login again when using the site normally even if a long time passes between each use.
// !! Definitely play around with this !!
func LoadInitialAuth(client *http.Client) {
	page, err := client.Get("https://toyhou.se/~account/login");
	if err != nil {
		log.Fatal(err);
	}

	viper.SetConfigFile(".env")
	viper.ReadInConfig();

	username, ok := viper.Get("toyhouse_username") . (string);
	if !ok {
		log.Fatal("Something went wrong while reading username from .env file!");
	}
	password, ok := viper.Get("toyhouse_password") . (string);
	if !ok {
		log.Fatal("Something went wrong while reading password from .env file!");
	}

	doc, err := goquery.NewDocumentFromReader(page.Body);

	if err != nil {
		log.Fatal(err);
	}

	csrf_token, ok := doc.Find("meta[name='csrf-token']").Attr("content");

	if !ok {
		log.Fatal("Something went wrong while reading csrf token element!");
	}


	fmt.Println("CSRF TOKEN:", csrf_token);
	form_data := url.Values{
		"username": { username },
		"password": { password },
		"_token": { csrf_token },
	}

	url, err := url.Parse("https://toyhou.se");
	println("Posting login form with data:", form_data.Encode());
	fmt.Printf("Cookies: %v\n", client.Jar.Cookies(url));
	client.PostForm("https://toyhou.se/~account/login", form_data);

	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Cookies: %v\n", client.Jar.Cookies(url));
}

func GetAuthorizedUsers(client *http.Client) []string {
	var all_usernames []string;

	get_usernames := func(doc *goquery.Document) []string {
		var usernames []string;
		doc.Find("a.user-name-badge").Each(func(i int, ele *goquery.Selection) {
			username := ele.Text();
			usernames = append(usernames, username);
		});

		return usernames
	}

	scraper.SaveWithPagination(client, "https://toyhou.se/~account/authorizers", all_usernames, get_usernames)

	return all_usernames;
}

func EnsureUserHasAccess(char *structs.Character, auths []string) (bool, error) {
	for _, username := range auths {
		if username == char.Owner {
			return true, nil;
		}
	}

	return false, errors.New("Username not in auths array");
}