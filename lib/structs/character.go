package structs

type Character struct {
	Id string `json:"id" binding:"required"`
	Name string `json:"name" binding:"required"`
	Image string `json:"image,omitempty"`
	Gallery []Image `json:"gallery,omitempty"`
	Favorites []Profile `json:"favorites,omitempty"`
	Comments []Comment `json:"comments,omitempty"`
	Owner Profile `json:"owner" binding:"required"`
}