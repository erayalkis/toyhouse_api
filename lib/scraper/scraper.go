package scraper

import "fmt"


func ScrapeUser() {

}

func ScrapeCharacter(user_id string) string {
	fmt.Println("Scraping user", user_id)
	full_url := fmt.Sprint("https:/toyhou.se/", user_id)

	return full_url
}