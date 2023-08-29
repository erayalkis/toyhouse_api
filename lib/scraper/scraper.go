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

	character.Id = character_id;
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
				Image: image,
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
	
	character.Id = character_id;
	return character, locked
}

func ScrapeCharacterComments(character_id string, client *http.Client) (structs.Character, bool) {
	fmt.Println("Scraping comments for", character_id)
	full_url := fmt.Sprint("https://toyhou.se/", character_id, "/comments")

	res, err := client.Get(full_url)
	if err != nil {
		log.Fatal(err)
	}

	doc, err := goquery.NewDocumentFromReader(res.Body);
	if err != nil {
		log.Fatal(err)
	}

	name := doc.Find(".comments-title a").Text()
	owner_name := doc.Find("span.display-user a span.display-user-username").Text()
	owner_link := doc.Find("span.display-user a").AttrOr("href", "none")

	fmt.Println("Fetching", full_url)
	
	get_comments := func(doc *goquery.Document) []structs.Comment {
		var comments []structs.Comment

		doc.Find("div.forum-post-post").Each(func(i int, ele *goquery.Selection) {
			user_avatar := ele.Find("div.forum-post-avatar > img").AttrOr("src", "none")
			user_name := ele.Find("a.user-name-badge").Text()
			user_link := ele.Find("a.user-name-badge").AttrOr("href", "none")
			text := ele.Find("div.user-content").Text()

			comment := structs.Comment{
				User: structs.Profile{
					Name: user_name,
					Link: user_link,
					Image: user_avatar,
				},
				Body: text,
			}

			comments = append(comments, comment)
		})

		return comments
	}

	all_comments, locked := SaveWithPagination(client, full_url, get_comments);

	character := structs.Character{
		Name: name,
		Owner: structs.Profile{
			Name: owner_name,
			Link: owner_link,
		},
		Comments: all_comments,
	}

	character.Id = character_id;
	return character, locked
}

func ScrapeCharacterOwnership(character_id string, client *http.Client) ([]structs.OwnershipLog, bool) {
	fmt.Println("Scraping character ownsership logs for:", character_id)
	full_url := fmt.Sprint("https://toyhou.se/", character_id, "/ownership/logs");

	fmt.Println("Fetching", full_url);
	res, err := client.Get(full_url);
	
	if err != nil {
		log.Fatal(err);
	}

	doc, err := goquery.NewDocumentFromReader(res.Body);

	if err != nil {
		log.Fatal(err);
	}

	log, locked := getCharacterDataFromOwnershipPage(doc, client, full_url);

	return log, locked;
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
					Link: "https://toyhou.se" + char_link,
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

func getCharacterDataFromOwnershipPage(doc *goquery.Document, client *http.Client, url string) ([]structs.OwnershipLog, bool) {
	get_images := func(doc *goquery.Document) []structs.OwnershipLog { 
		var logs []structs.OwnershipLog;
		
		doc.Find("tr.row").Each(func(i int, ele *goquery.Selection) {
			log_date := ele.Find("td.col-4").Text()
			log_desc := ele.Find("td.col-8").Text()
			log_user := ele.Find("td.col-8 span.display-user")
			log_user_username := log_user.Text()
			log_user_link := log_user.AttrOr("href", "N/A")

			log := structs.OwnershipLog {
				Date: log_date,
				Description: log_desc,
				TaggedUser: structs.Profile {
					Name: log_user_username,
					Link: log_user_link,
				},
			}

			logs = append(logs, log)
		})

		return logs;
	}

	all_logs, locked := SaveWithPagination(client, url, get_images);

	return all_logs, locked;
}

func ScraperCharacterDetails(character_id string, client *http.Client) (structs.Character, bool) {
	fmt.Println("Fetching details for", character_id)
	full_url := fmt.Sprint("https://toyhou.se/", character_id, "/gallery")

	res, err := client.Get(full_url)
	if err != nil {
		log.Fatal(err)
	}

	doc, err := goquery.NewDocumentFromReader(res.Body)

	owner_anchor := doc.Find("span.display-user a")
	owner_name := owner_anchor.Find("span.display-user-username").Text()
	owner_link := owner_anchor.AttrOr("href", "none")
	character_anchor := doc.Find("li.character-name span.display-character a")
	character_name := character_anchor.Text()
	character_image := character_anchor.Find("img").AttrOr("src", "none")
	locked := doc.Find("h1.image-gallery-title i.fa-unlock-alt").Length() > 0

	character := structs.Character{
		Id: character_id,
		Owner: structs.Profile{
			Name: owner_name,
			Link: owner_link,
		},
		Name: character_name,
		Image: character_image,
	}


	return character, locked
}

func ScrapeUser() {}

func ScrapeUserSubs(user_id string, client *http.Client) []structs.Profile {
	fmt.Println("Scraping subscribers of", user_id)
	full_url := fmt.Sprint("https://toyhou.se/", user_id, "/stats/subscribers");

	get_subs := func(doc *goquery.Document) []structs.Profile {
		var subs []structs.Profile

		doc.Find("div.character-select-cell").Each(func(i int, ele *goquery.Selection) {
			avatar := ele.Find("img.mw-100").AttrOr("src", "none")
			name := ele.Find("a.user-name-badge").Text()
			link := ele.Find("a.user-name-badge").AttrOr("href", "none")

			user := structs.Profile {
				Image: avatar,
				Name: name,
				Link: link,
			}

			subs = append(subs, user)
		})

		return subs
	}

	all_subs, _ := SaveWithPagination(client, full_url, get_subs)

	return all_subs
}
// Given an array `data`, goes through each page, provides callback to process page's data, adds the array returned from the callback to the data array
//
// The callback **must** return an array
//
// *V* is a generic parameter that can either be `string` or `structs.Image`
func SaveWithPagination[V string | structs.Image | structs.Profile | structs.Comment | structs.OwnershipLog](client *http.Client, baseUrl string, callback func(doc *goquery.Document) []V) ([]V, bool) {
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