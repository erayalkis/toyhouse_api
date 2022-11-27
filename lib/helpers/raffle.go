package helpers

import (
	"net/http"
	"toyhouse_api/v2/lib/scraper"
	"toyhouse_api/v2/lib/structs"
)

func CalculateRaffleTickets(character_id string, client *http.Client, user_must_sub bool, user_must_comment bool) map[string]structs.Ticket {
	tickets := make(map[string]structs.Ticket);

	character, _ := scraper.ScrapeCharacterFavorites(character_id, client)
	owner := character.Owner.Name
	for _, fav := range character.Favorites {
		name := fav.Name
		image := fav.Avatar
		count := 1

		ticket := structs.Ticket {
			Avatar: image,
			Tickets: count,
		}

		tickets[name] = ticket
	}

	if user_must_comment {
		character, _ := scraper.ScrapeCharacterComments(character_id, client)
		
		seen := make(map[string]bool)
		for _, comment := range character.Comments {
			username := comment.User.Name
			_, ok := tickets[username]
			_, seen := seen[username]
			user_can_participate := ok
			user_unique := !seen
			if user_can_participate && user_unique {
				user := tickets[username]
				user.Tickets = 10
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
				user.Tickets = 20
				tickets[username] = user
			}
		}
	}

	return tickets;
}