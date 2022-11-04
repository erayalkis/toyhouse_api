package scraper

import (
	"fmt"
	"log"
	"net/http"
	"net/url"
	"toyhouse_api/v2/lib/structs"

	"github.com/PuerkitoBio/goquery"
)

func ScrapeUser() {}

func ScrapeCharacter(character_id string, client *http.Client) structs.Character {
	fmt.Println("Scraping characterr", character_id)
	url, err := url.Parse("https://toyhou.se");
	full_url := fmt.Sprint("https://toyhou.se/", character_id, "/gallery");

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

	character := structs.Character {
		Name: name,
		Images: images,
	}

	return character;
}