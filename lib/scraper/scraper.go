package scraper

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
	"sync"
	"toyhouse_api/v2/lib/structs"

	"github.com/PuerkitoBio/goquery"
)

func ScrapeUser() {}

func ScrapeCharacterGallery(character_id string, client *http.Client) (structs.Character, bool) {
	fmt.Println("Scraping character", character_id)
	full_url := fmt.Sprint("https://toyhou.se/", character_id, "/gallery");

	res, err := client.Get(full_url);
	
	if err != nil {
		log.Fatal(err);
	}

	doc, err := goquery.NewDocumentFromReader(res.Body);

	if err != nil {
		log.Fatal(err);
	}

	character, locked := getCharacterDataFromGalleryPage(doc, client, full_url);

	return character, locked;
}

func getCharacterDataFromGalleryPage(doc *goquery.Document, client *http.Client, url string) (structs.Character, bool) {
	name := doc.Find("h1.image-gallery-title a").Text();
	owner := doc.Find("span.display-user a").First().Text();
	locked := doc.Find("h1.image-gallery-title i.fa-unlock-alt").Length() > 0

	get_images := func(doc *goquery.Document) []string {
		var images []string;
		doc.Find(".magnific-item").Each(func(i int, ele *goquery.Selection ) {
			link, ok := ele.Find("img").Attr("src");
			if ok {
				images = append(images, link);
			}
		})

		return images;
	}

	all_images := SaveWithPagination(client, url, get_images);


	character := structs.Character {
		Name: name,
		Images: all_images,
		Owner: owner,
	}

	return character, locked;
}


// Given an array `data`, goes through each page, provides callback to process page's data, adds the array returned from the callback to the data array
//
// The callback **must** return an array
func SaveWithPagination(client *http.Client, baseUrl string, callback func(doc *goquery.Document) []string) []string {
	idx := 1;
	newUrl := fmt.Sprint(baseUrl, "?page=", idx);
	page, err := client.Get(newUrl);
	if err != nil {
		log.Fatal(err)
	}

	doc, err := goquery.NewDocumentFromReader(page.Body);

	var pagination_items *goquery.Selection;
	var last_idx int;
	var limit string;
	var limit_int int;

	if(doc.Find("ul.pagination")).Length() > 0 {
		pagination_items = doc.Find("li.page-item")
		last_idx = pagination_items.Length() - 1;
		limit = pagination_items.Slice(0, last_idx).Last().Text();
		
		limit_int, err = strconv.Atoi(limit);
	} else {
		limit_int = 1
	}

	var data []string;

	ret := callback(doc);
	data = append(data, ret...);
	idx++

	var waitGroup sync.WaitGroup;

	var urls []string;
	fmt.Println("Generating urls from", idx, "to", limit_int);
	for i := idx; i < limit_int; i++ {
		newUrl := fmt.Sprint(baseUrl, "?page=", i);
		fmt.Println("Got", newUrl);
		urls = append(urls, newUrl);
	}
	fmt.Println("Generating urls complete")

	fmt.Printf("urls: %v\n", urls);

	for _, url := range urls {
		fmt.Println("Fetching", url);
		waitGroup.Add(1)

		fetch := func(url string) { 
			defer waitGroup.Done();

			page, err = client.Get(url);
			doc, err = goquery.NewDocumentFromReader(page.Body);
			ret := callback(doc);
			data = append(data, ret...);
			fmt.Println("Fetch for", url, "complete");
		}

		go fetch(url);
	}

	waitGroup.Wait()

	return data;
}