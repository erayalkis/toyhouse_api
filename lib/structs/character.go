package structs

type Character struct {
	Name string `json:"name" binding:"required"`
	Gallery []Image `json:"gallery" binding:"required"`
	Owner Profile `json:"owner" binding:"required"`
}