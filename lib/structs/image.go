package structs

type Image struct {
	Link string `json:"link" binding:"required"`
	Artists []Profile `json:"artists" binding:"required"`
}