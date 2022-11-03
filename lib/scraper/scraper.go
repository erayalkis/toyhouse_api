package scraper

import (
	"fmt"
	"log"
	"net/http"
	"net/url"

	"github.com/PuerkitoBio/goquery"
)

type Character struct {
	Name string `json:"name" binding:"required"`
	Images []string `json:"images" binding:"required"`
}

func ScrapeUser() {}

func ScrapeCharacter(user_id string, client *http.Client) Character {
	fmt.Println("Scraping user", user_id)
	url, err := url.Parse("https://toyhou.se");
	full_url := fmt.Sprint("https://toyhou.se/", user_id, "/gallery");

	fmt.Printf("Cookies: %v\n", client.Jar.Cookies(url));
	res, err := client.Get(full_url);
	fmt.Printf("Cookies: %v\n", client.Jar.Cookies(url));
	
	if err != nil {
		log.Fatal(err);
	}

	doc, err := goquery.NewDocumentFromReader(res.Body);

	if err != nil {
		log.Fatal(err);
	}

	name := doc.Find("h1.image-gallery-title a").Text();
	var images []string;
 	doc.Find(".magnific-item").Each(func(i int, ele *goquery.Selection ) {
		link, ok := ele.Find("img").Attr("src");
		if ok {
			images = append(images, link);
		}
	})


	character := Character {
		Name: name,
		Images: images,
	}

	return character;
}