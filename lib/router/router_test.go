package router_test

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"toyhouse_api/v2/lib/router"

	"github.com/magiconair/properties/assert"
)

func TestRouterAlive(t *testing.T) {	
	router := router.SetRoutes()

	recorder := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/ping", nil)
	router.ServeHTTP(recorder, req)

	assert.Equal(t, 200, recorder.Code)
	assert.Equal(t, "pong", recorder.Body.String())
}