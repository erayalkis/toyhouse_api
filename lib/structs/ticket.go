package structs

type Ticket struct {
	Image string `json:"image" binding:"required"`
	Tickets int `json:"ticket_count" binding:"required"`
}