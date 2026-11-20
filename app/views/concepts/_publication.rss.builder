xml.item do
	xml.guid    publication_url(publication.publication_work_id)
	xml.title   publication.title
	xml.link    publication_url(publication.publication_work_id)
	xml.pubDate DateTime.parse(publication.published_at).rfc822
end
