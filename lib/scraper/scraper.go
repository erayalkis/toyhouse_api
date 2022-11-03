package scraper

import (
	"fmt"
	"log"
	"net/http"
	"net/http/cookiejar"

	"github.com/PuerkitoBio/goquery"
)

type Character struct {
	Name string `json:"name" binding:"required"`
	Images []string `json:"images" binding:"required"`
}

func ScrapeUser() {}

func ScrapeCharacter(user_id string) Character {
	fmt.Println("Scraping user", user_id)
	full_url := fmt.Sprint("https://toyhou.se/", user_id, "/gallery");
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

	name := doc.Find("h1.image-gallery-title a").Text();
	var images []string;
 	doc.Find(".magnific-item").Each(func(i int, ele *goquery.Selection ) {
		link, _ := ele.Find("img").Attr("href");
		images = append(images, link);
	})

	character := Character {
		Name: name,
		Images: images,
	}

	fmt.Println(character);
	return character;
}