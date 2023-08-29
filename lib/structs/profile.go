package structs

type Profile struct {
	Name string `json:"name,omitempty"`
	Link string `json:"link,omitempty"`
	Image string `json:"image,omitempty"`
}