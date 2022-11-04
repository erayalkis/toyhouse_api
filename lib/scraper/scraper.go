package scraper

import (
	"fmt"
	"log"
	"net/http"
	"net/url"
	"strconv"
	"toyhouse_api/v2/lib/structs"

	"github.com/PuerkitoBio/goquery"
)

func ScrapeUser() {}

func ScrapeCharacterGallery(character_id string, client *http.Client) (structs.Character, bool) {
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

	character, locked := getCharacterDataFromGalleryPage(doc);

	return character, locked;
}

func getCharacterDataFromGalleryPage(doc *goquery.Document) (structs.Character, bool) {
	name := doc.Find("h1.image-gallery-title a").Text();
	owner := doc.Find("span.display-user a").First().Text();
	var images []string;
 	doc.Find(".magnific-item").Each(func(i int, ele *goquery.Selection ) {
		link, ok := ele.Find("img").Attr("src");
		if ok {
			images = append(images, link);
		}
	})

	locked := doc.Find("i.fa-unlock-alt").Length() > 0

	character := structs.Character {
		Name: name,
		Images: images,
		Owner: owner,
	}

	return character, locked;
}


// Given an array `data`, goes through each page, provides callback to process page's data, adds the array returned from the callback to the data array
//
// The callback **must** return an array
func SaveWithPagination(client *http.Client, baseUrl string, data []string, callback func(doc *goquery.Document) []string) []string {
	fmt.Println("Hit pagination");
	idx := 1;
	newUrl := fmt.Sprint(baseUrl, "?page=", idx);
	fmt.Println("Fetching", baseUrl);
	page, err := client.Get(newUrl);
	doc, err := goquery.NewDocumentFromReader(page.Body);
	if(doc.Find("ul.pagination")).Length() == 0 {
		log.Fatal("Page", newUrl, "does not use pagination");
	}
	pagination_items := doc.Find("li.page-item")
	last_idx := pagination_items.Length() - 1;
	limit := pagination_items.Slice(0, last_idx).Last().Text();
	
	limit_int, err := strconv.Atoi(limit);
	fmt.Println("Limit is", limit);
	fmt.Println("Initial page fetched")


	if err != nil {
		log.Fatal(err)
	}

	for page != nil {
		if idx > limit_int {
			break
		}

		doc, err = goquery.NewDocumentFromReader(page.Body);
		if err != nil {
			log.Fatal(err)
		}

		ret := callback(doc);
		data = append(data, ret...);

		url := fmt.Sprint(baseUrl, "?page=", idx);
		fmt.Println("Fetching", url)
		page, err = client.Get(url);
		fmt.Println("Code", page.StatusCode);
		fmt.Println("Page", idx, "fetched");

		idx++;
	}


	return data;
}