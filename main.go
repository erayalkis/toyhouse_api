package main

import (
	"os"
	"toyhouse_api/v2/lib/router"
) 

func main() {
	// gin.SetMode(gin.ReleaseMode);

	server := router.SetRoutes();

	// Get port from environment variable (Render sets PORT)
	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}

	server.Run(":" + port);
}