package helpers

import (
	"net/http"
	"toyhouse_api/v2/lib/scraper"
	"toyhouse_api/v2/lib/structs"
)

func CalculateRaffleTickets(character_id string, client *http.Client, user_must_sub bool, user_must_comment bool, fav_count int, sub_count int, comment_count int) map[string]structs.Ticket {
	tickets := make(map[string]structs.Ticket);

	character, _ := scraper.ScrapeCharacterFavorites(character_id, client)
	owner := character.Owner.Name
	for _, fav := range character.Favorites {
		count := fav_count

		ticket := structs.Ticket {
			Tickets: count,
			Profile: fav,
		} 

		tickets[fav.Name] = ticket
	}

	if user_must_comment {
		character, _ := scraper.ScrapeCharacterComments(character_id, client)
		
		seen := make(map[string]bool)
		for _, comment := range character.Comments {
			username := comment.User.Name
			_, ok := tickets[username]
			_, in_seen := seen[username]
			user_can_participate := ok
			user_unique := !in_seen
			if user_can_participate && user_unique {
				seen[username] = true
		
				user := tickets[username]
				user.Tickets += comment_count
				tickets[username] = user
			}
		}
	}

	if user_must_sub {
		subs := scraper.ScrapeUserSubs(owner, client)

		for _, user := range subs {
			username := user.Name
			_, ok := tickets[username]
			user_can_participate := ok

			if user_can_participate {
				user := tickets[username]
				user.Tickets += sub_count
				tickets[username] = user
			}
		}
	}

	return tickets;
}