package router

import (
	"fmt"
	"net/http"
	"net/http/cookiejar"
	"toyhouse_api/v2/lib/auth"
	"toyhouse_api/v2/lib/scraper"

	"github.com/gin-gonic/gin"
)

func setCORS() gin.HandlerFunc {
	fmt.Println("Setting CORS");

	return func(c *gin.Context) {
		  c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
      c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
      c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
      c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT")

			if c.Request.Method == "OPTIONS" {
        c.AbortWithStatus(204)
        return
      }

      c.Next()
	}
}

func SetRoutes() *gin.Engine {
	server := gin.Default();
	server.LoadHTMLFiles("./static/index.html")
	
	jar, _ := cookiejar.New(nil);
	client := http.Client{
		Jar: jar,
	}

	auth.LoadInitialAuth(&client);

	server.Use(setCORS())
	server.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", nil);
	})

	server.GET("/ping", func(c *gin.Context) {
		c.String(http.StatusOK, "pong");
	})

	server.GET("/app_status", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Server is up and running",
		})
	})

	server.GET("/user/:id/details", func(c *gin.Context) {
		user_id := c.Param("id");

		scraper.ScrapeUser();
		c.String(http.StatusOK, "Hello %s", user_id);
	})

	server.GET("/character/:id/gallery", func(c *gin.Context) {
		character_id := c.Param("id");

		character, locked := scraper.ScrapeCharacterGallery(character_id, &client);
		if locked {
			auths := auth.GetAuthorizedUsers(&client);
			fmt.Printf("auths: %v\n", auths)
			ok, _ := auth.EnsureUserHasAccess(&character, auths);
			if !ok {
				c.JSON(http.StatusForbidden, gin.H{
					"error": "You do not have access to this character!",
				})
				return;
			}
		}


		c.JSON(http.StatusOK, character);
	})

	server.GET("/character/:id/:tabId/gallery", func(c *gin.Context) {
		character_id := c.Param("id");
		tab_id := c.Param("tabId");
		complete_url := fmt.Sprint(character_id, "/", tab_id)

		character, locked := scraper.ScrapeCharacterGallery(complete_url, &client);
		if locked {
			auths := auth.GetAuthorizedUsers(&client);
			fmt.Printf("auths: %v\n", auths)
			ok, _ := auth.EnsureUserHasAccess(&character, auths);
			if !ok {
				println("User unauthorized")
				c.JSON(http.StatusForbidden, gin.H{
					"error": "You do not have access to this character!",
				})
				return
			}
			println("User authorized")
		}

		c.JSON(http.StatusOK, character);
	})

	server.GET("/character/:id/favorites", func(c *gin.Context) {
		character_id := c.Param("id");

		character, locked := scraper.ScrapeCharacterFavorites(character_id, &client);
		if locked {
			auths := auth.GetAuthorizedUsers(&client);
			fmt.Printf("auths: %v\n", auths);

			ok, _ := auth.EnsureUserHasAccess(&character, auths);
			if !ok {
				c.JSON(http.StatusForbidden, gin.H{
					"error": "You do not have access to this character!",
				})
				return;
			}
		}
	
		c.JSON(http.StatusOK, character);
	})

	server.GET("/raffle/:id", func(c *gin.Context) {		
	})

	return server;
} 