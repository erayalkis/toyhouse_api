package helpers

import (
	"net/http"
	"toyhouse_api/v2/lib/scraper"
	"toyhouse_api/v2/lib/structs"
)

func CalculateRaffleTickets(character_id string, client *http.Client, user_must_sub bool, user_must_comment bool, fav_count int, sub_count int, comment_count int) []structs.Ticket {
	var tickets []structs.Ticket;

	character, _ := scraper.ScrapeCharacterFavorites(character_id, client)
	owner := character.Owner.Name
	for _, fav := range character.Favorites {
		count := fav_count

		ticket := structs.Ticket {
			Profile: fav,
			Tickets: count,
		}

		tickets = append(tickets, ticket)
	}

	if user_must_comment {
		character, _ := scraper.ScrapeCharacterComments(character_id, client)
		
		seen := make(map[string]bool)
		for _, comment := range character.Comments {
			username := comment.User.Name
			_, in_seen := seen[username]

			var user structs.Ticket
			var userIdx int
			for i := range tickets {
				if (tickets[i].Profile.Name == comment.User.Name) {
					user = tickets[i]
					userIdx = i
				}
			}
				
			user_can_participate := user != structs.Ticket{};
			user_unique := !in_seen

			if user_can_participate && user_unique {
				seen[username] = true

				user.Tickets += comment_count
				tickets[userIdx] = user
			}
		}
	}

	if user_must_sub {
		subs := scraper.ScrapeUserSubs(owner, client)

		for _, user := range subs {
			userIdx := 0
			for i := range tickets {
				if (tickets[i].Profile.Name == user.Name) {
					userIdx = i
				}
			}

			ok := userIdx != 0;
			user_can_participate := ok

			if user_can_participate {
				user := tickets[userIdx]
				user.Tickets += sub_count
				tickets[userIdx] = user
			}
		}
	}

	return tickets;
}