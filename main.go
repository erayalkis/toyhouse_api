package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	server := gin.Default();
	server.LoadHTMLFiles("index.html")

	server.GET("/", func(c *gin.Context) {
		// c.JSON(http.StatusOK, gin.H{"data": "Hello World!"})
		c.HTML(http.StatusOK, "index.html", nil);
	})

	server.Run();
}