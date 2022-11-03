package main

import (
	"net/http"

	"toyhouse_api/v2/lib/scraper"

	"github.com/gin-gonic/gin"
)

func main() {
	server := gin.Default();
	server.LoadHTMLFiles("./static/index.html")

	server.GET("/", func(c *gin.Context) {
		// c.JSON(http.StatusOK, gin.H{"data": "Hello World!"})
		c.HTML(http.StatusOK, "index.html", nil);
	})

	server.GET("/user/:id/details", func(c *gin.Context) {
		user_id := c.Param("id");

		scraper.ScrapeUser();
		c.String(http.StatusOK, "Hello %s", user_id);
	})

	server.GET("/character/:id/gallery", func(c *gin.Context) {
		character_id := c.Param("id");

		url := scraper.ScrapeCharacter(character_id);
		c.String(http.StatusOK, "Character with ID %s %s", character_id, url);
	})

	server.Run();
}