package structs

type Profile struct {
	Name string `json:"name" binding:"required"`
	Link string `json:"link" binding:"required"`
	Image string `json:"image,omitempty"`
}