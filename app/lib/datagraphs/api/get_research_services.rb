module Datagraphs
  module Api
    class GetResearchServices < CypherQuery

      QUERY = <<-Q
  MATCH path1=(rs:ResearchService)-[r1:for]->(h:House)
  RETURN rs.id AS id, rs.name AS name, rs.shortName AS short_name, rs.strapLine AS strap_line, rs.isDefunct AS is_Defunct, count(rs.hasPublicationWork) AS count_rs_hasPublicationWork_6, collect(h.id) AS house_ids, collect(h.name) AS house_names
      Q

      def process
        Rails.logger.info("Calling get research services")
        params = { query: QUERY }
        response = call(params: params)
        Rails.logger.info("Called get research services")
        process_response(response.body)
      end
    end
  end
end
