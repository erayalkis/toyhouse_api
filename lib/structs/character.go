package structs

type Character struct {
	Name string `json:"name" binding:"required"`
	Gallery []Image `json:"gallery,omitempty"`
	Favorites []Profile `json:"favorites,omitempty"`
	Owner Profile `json:"owner" binding:"required"`
}