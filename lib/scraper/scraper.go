package scraper

import (
	"fmt"
	"log"
	"net/http"
	"net/http/cookiejar"

	"github.com/PuerkitoBio/goquery"
)


func ScrapeUser() {

}

func ScrapeCharacter(user_id string) string {
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

	fmt.Printf("doc.Text(): %v\n", doc.Text())

	return full_url
}