package structs

type Image struct {
	Link string `json:"link" binding:"required"`
	Artists []Profile `json:"artists" binding:"required"`
	Metadata ImageMetadata `json:"image_metadata" binding:"required"`
}