package main

import (
	"net/http"
	"net/http/cookiejar"
	"toyhouse_api/v2/lib/auth"
	"toyhouse_api/v2/lib/scraper"

	"github.com/gin-gonic/gin"
)

func main() {
	server := gin.Default();
	server.LoadHTMLFiles("./static/index.html")
	
	jar, _ := cookiejar.New(nil);
	client := http.Client{
		Jar: jar,
	}

	auth.LoadInitialAuth(&client);

	server.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", nil);
	})

	server.Use(auth.AuthorizeIfAuthNotValid);

	server.GET("/user/:id/details", func(c *gin.Context) {
		user_id := c.Param("id");

		scraper.ScrapeUser();
		c.String(http.StatusOK, "Hello %s", user_id);
	})

	server.GET("/character/:id/gallery", func(c *gin.Context) {
		character_id := c.Param("id");

		character := scraper.ScrapeCharacter(character_id, &client);
		c.JSON(http.StatusOK, character);
	})

	server.Run();
}