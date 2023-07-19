package main

import (
	"toyhouse_api/v2/lib/router"
) 

func main() {
	// gin.SetMode(gin.ReleaseMode);

	server := router.SetRoutes();

	server.Run(":8081");
}