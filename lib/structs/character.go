package structs

type Character struct {
	Id string `json:"id,omitempty"`
	Name string `json:"name,omitempty"`
	Image string `json:"image,omitempty"`
	Gallery []Image `json:"gallery,omitempty"`
	Favorites []Profile `json:"favorites,omitempty"`
	Comments []Comment `json:"comments,omitempty"`
	Ownership []OwnershipLog `json:"ownership,omitempty"`
	Owner Profile `json:"owner,omitempty"`
}