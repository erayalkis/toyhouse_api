package structs

type Character struct {
	Name string `json:"name" binding:"required"`
	Images []string `json:"images" binding:"required"`
	Owner string `json:"owner" binding:"required"`
}