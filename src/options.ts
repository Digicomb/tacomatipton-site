// Choices offered in the contact form. Shared by the page buttons that preselect them.
// If you rename or add one, update the tt_contact_topic_valid / tt_contact_location_valid
// checks in the database too.
export const topics = [
	{ value: 'Renting', label: 'I’m looking for a home to rent' },
	{ value: 'Maintenance', label: 'I’m a resident with a repair request' },
	{ value: 'Resident', label: 'I’m a resident with another question' },
	{ value: 'Other', label: 'Something else' },
];

export const locations = [
	{ value: 'Akron, OH', label: 'Akron, Ohio' },
	{ value: 'New Albany, IN', label: 'New Albany, Indiana' },
	{ value: 'Either', label: 'Either / not sure yet' },
];
