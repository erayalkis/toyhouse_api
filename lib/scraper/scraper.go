package scraper

import (
	"fmt"
	"log"
	"net/http"
	"net/http/cookiejar"

	"github.com/PuerkitoBio/goquery"
)

// type Character struct {
// 	name string
// }

func ScrapeUser() {}

func ScrapeCharacter(user_id string) map[string]string {
	fmt.Println("Scraping user", user_id)
	full_url := fmt.Sprint("https://toyhou.se/", user_id)
	jar, _ := cookiejar.New(nil);

	client := http.Client{
		Jar: jar,
	}

	res, err := client.Get(full_url);
	
	if err != nil {
		log.Fatal(err);
	}

	doc, err := goquery.NewDocumentFromReader(res.Body);

	if err != nil {
		log.Fatal(err);
	}

	name := doc.Find("h1.display-4").Text();

	character := map[string]string {
		"name": name,
	}

	fmt.Println(character);
	return character;
}