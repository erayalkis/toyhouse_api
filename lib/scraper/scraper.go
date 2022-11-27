package scraper

import (
	"fmt"
	"log"
	"net/http"
	"sort"
	"strconv"

	"sync"
	"toyhouse_api/v2/lib/structs"

	"github.com/PuerkitoBio/goquery"
)

func ScrapeUser() {}

func ScrapeCharacterGallery(character_id string, client *http.Client) (structs.Character, bool) {
	fmt.Println("Scraping character", character_id)
	full_url := fmt.Sprint("https://toyhou.se/", character_id, "/gallery");

	fmt.Println("Fetching", full_url);
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

func ScrapeCharacterFavorites(character_id string, client *http.Client) (structs.Character, bool) {
	fmt.Println("Scraping favorites for", character_id);
	full_url := fmt.Sprint("https://toyhou.se/", character_id, "/favorites")

	res, err := client.Get(full_url)
	if err != nil {
		log.Fatal(err)
	}

	doc, err := goquery.NewDocumentFromReader(res.Body);
	if err != nil {
		log.Fatal(err)
	}

	name := doc.Find(".favorites-title a").Text()
	owner_name := doc.Find("span.display-user a span.display-user-username").Text()
	owner_link := doc.Find("span.display-user a").AttrOr("href", "none")

	fmt.Println("Fetching", full_url)

	get_favorites := func(doc *goquery.Document) []structs.Profile {
		var users []structs.Profile;

		doc.Find("div.user-cell").Each(func(i int, ele *goquery.Selection) {
			image := ele.Find(".user-icon img").AttrOr("src", "none");
			name := ele.Find(".user-name a").Text()
			link := ele.Find(".user-name a").AttrOr("href", "none")

			user := structs.Profile{
				Avatar: image,
				Name: name,
				Link: link,
			}

			users = append(users, user)
		})

		return users;
	}

	all_users, locked := SaveWithPagination(client, full_url, get_favorites);

	character := structs.Character{
		Name: name,
		Owner: structs.Profile{
			Name: owner_name,
			Link: owner_link,
		},
		Favorites: all_users,
	}
	return character, locked
}

func getCharacterDataFromGalleryPage(doc *goquery.Document, client *http.Client, url string) (structs.Character, bool) {
	name := doc.Find("h1.image-gallery-title a").Text();
	owner_box := doc.Find("span.display-user a").First()
	owner := structs.Profile{
		Name: owner_box.Text(),
		Link: owner_box.AttrOr("href", "error"),
	}

	locked := doc.Find("h1.image-gallery-title i.fa-unlock-alt").Length() > 0

	get_images := func(doc *goquery.Document) []structs.Image {
		var images []structs.Image;
		
		doc.Find(".gallery-item").Each(func(i int, ele *goquery.Selection ) {
			artists := []structs.Profile{}
			tagged_characters := []structs.Profile{}

			artists_div := ele.Find("div.artist-credit")
			characters_div := ele.Find("div.image-characters div.mb-1")
			link := ele.Find("div.thumb-image a").First().AttrOr("href", "none")
			date := ele.Find("div.image-credits > div.mb-1").First().Text()
			desc := ele.Find("div.image-description").Text()

			artists_div.Each(func(i int, artist *goquery.Selection) {
				artist_name := artist.Find("a").Text()
				artist_link := artist.Find("a").AttrOr("href", "none")

				artist_obj := structs.Profile{
					Name: artist_name,
					Link: artist_link,
				}

				artists = append(artists, artist_obj)
			})

			characters_div.Each(func(i int, character *goquery.Selection) {
				char_name := character.Find("a").Text()
				char_link := character.Find("a").AttrOr("href", "none")

				char_obj := structs.Profile{
					Name: char_name,
					Link: char_link,
				}

				tagged_characters = append(tagged_characters, char_obj)
			})

			image := structs.Image{
				Link: link,
				Artists: artists,
				Metadata: structs.ImageMetadata{
					Date: date,
					Description: desc,
					TaggedCharacters: tagged_characters,
				},
			}

			images = append(images, image)
		})

		return images;
	}

	all_images, locked := SaveWithPagination(client, url, get_images);


	character := structs.Character {
		Name: name,
		Gallery: all_images,
		Owner: owner,
	}

	return character, locked;
}


// Given an array `data`, goes through each page, provides callback to process page's data, adds the array returned from the callback to the data array
//
// The callback **must** return an array
//
// *V* is a generic parameter that can either be `string` or `structs.Image`
func SaveWithPagination[V string | structs.Image | structs.Profile](client *http.Client, baseUrl string, callback func(doc *goquery.Document) []V) ([]V, bool) {
	var data []V;
	var urls []string;
	pages := make(map[int][]V);
	var waitGroup sync.WaitGroup;

	idx := 1;
	newUrl := fmt.Sprint(baseUrl, "?page=", idx);
	page, err := client.Get(newUrl);
	if err != nil {
		log.Fatal(err)
	}
	doc, err := goquery.NewDocumentFromReader(page.Body);
	limit_int := getPaginationLimit(doc)
	locked := doc.Find("h1.image-gallery-title i.fa-unlock-alt").Length() > 0


	ret := callback(doc);
	pages[idx] = ret;
	idx++


	for i := idx; i <= limit_int; i++ {
		newUrl := fmt.Sprint(baseUrl, "?page=", i);
		urls = append(urls, newUrl);
	}

	for i, url := range urls {
		fmt.Println("Fetching", url);
		waitGroup.Add(1)

		fetch := func(i int, url string, ) { 
			defer waitGroup.Done();

			page, err = client.Get(url);
			doc, err = goquery.NewDocumentFromReader(page.Body);
			ret := callback(doc);

			pages[i + 2] = ret;

			fmt.Println("Fetch for", url, "complete");
		}

		go fetch(i, url);
	}

	waitGroup.Wait()

	keys := make([]int, 0, len(pages))
	for k := range pages {
		keys = append(keys, k)
	}

	sort.Ints(keys);

	fmt.Println(keys);

	for _, key := range keys {
		data = append(data, pages[key]...)
	}
	
	return data, locked;
}

func getPaginationLimit(doc *goquery.Document) int {
	var limit_int int;

	if(doc.Find("ul.pagination")).Length() > 0 {
		pagination_items := doc.Find("li.page-item")
		last_idx := pagination_items.Length() - 1;
		limit := pagination_items.Slice(0, last_idx).Last().Text();
		
		limit_int, _ = strconv.Atoi(limit);
	} else {
		limit_int = 1
	}
	
	return limit_int;
}