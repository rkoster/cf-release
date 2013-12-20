# If spiff complains of missing nodes, pipe its output into this script
# and STDOUT will be a YAML structure to complete the missing nodes.
#
# Usage:
#   $ templates/make_manifest openstack-nova
#   error generating manifest: unresolved nodes:
#      dynaml.MergeExpr{[properties cc bulk_api_password]}
#      ...
#   $ templates/make_manifest openstack-nova 2>&1 | ruby templates/stub-missing-nodes.rb
#   $ templates/make_manifest openstack-nova 2>&1 | ruby templates/stub-missing-nodes.rb > my-secrets.yml

require "yaml"

stubbed_nodes = {}
missing_value = "admin"

def add_stubbed_node(doc, sequence, value)
  if sequence.length > 1
    head, *tail = sequence
    doc[head] ||= {}
    add_stubbed_node(doc[head], tail, value)
  else
    head = sequence.first
    doc[head] = value
  end
end

# 2013/12/20 09:19:46 error generating manifest: unresolved nodes:
#      dynaml.MergeExpr{[properties cc bulk_api_password]}
#      dynaml.MergeExpr{[properties uaa jwt signing_key]}
#      dynaml.MergeExpr{[properties uaa clients space-mail secret]}
missing_node_text = STDIN.read
missing_node_text.scan(%r|dynaml\.MergeExpr\{\[(.*)\]\}|).each do |missing_node|
  # missing_node = ["properties cc staging_upload_password"]
  missing_node_sequence = missing_node.first.split(/ /)
  add_stubbed_node(stubbed_nodes, missing_node_sequence, missing_value)
end

puts stubbed_nodes.to_yaml