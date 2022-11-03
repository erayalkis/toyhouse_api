package auth

import (
	"fmt"
	"log"
	"net/http"
	"net/url"

	"github.com/PuerkitoBio/goquery"
	"github.com/gin-gonic/gin"
	"github.com/spf13/viper"
)

// Make request to /login, keep all the cookies
// I'm guessing the auth cookie should refresh if we have all the necessary cookies, since you never really have to login again when using the site normally even if a long time passes between each use.
// !! Definitely play around with this !!
func LoadInitialAuth(client *http.Client) {
	page, err := http.Get("https://toyhou.se/~account/login");
	viper.SetConfigFile(".env")
	viper.ReadInConfig();

	username, ok := viper.Get("toyhouse_username") . (string);
	password, ok := viper.Get("toyhouse_password") . (string);

	if err != nil {
		log.Fatal(err);
	}

	doc, err := goquery.NewDocumentFromReader(page.Body);

	if err != nil {
		log.Fatal(err);
	}

	csrf_token, ok := doc.Find("meta[name='csrf-token']").Attr("content");

	if !ok {
		log.Fatal(err);
	}


	fmt.Println("CSRF TOKEN:", csrf_token);
	form_data := url.Values{
		"username": { username },
		"password": { password },
		"_token": { csrf_token },
	}

	println("Posting login form with data:", form_data.Encode());
	client.PostForm("https://toyhou.se/login", form_data);
	url, err := url.Parse("https://toyhou.se");

	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Cookies: %v\n", client.Jar.Cookies(url));
}

// 
func AuthorizeIfAuthNotValid(c *gin.Context) {
	fmt.Println("Authorization happens here");

	c.Next();
}