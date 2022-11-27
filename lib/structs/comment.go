package structs

type Comment struct {
	User Profile `json:"user" binding:"required"`
	Body string `json:"body" binding:"required"`
}