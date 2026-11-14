# Graph Model: Shepherd App (Neo4j)

## Use Case

A graph database models the **relationships between people** in a church community: who mentors whom, which members are in the same groups, family connections, and discipleship chains. These relationship-centric queries are expensive in relational databases (recursive CTEs, multiple self-joins) but natural in a graph.

## Data Model (Cypher/Neo4j)

### Nodes

```cypher
// Members
CREATE (emeka:Member {id: "mem_001", name: "Emeka Okafor", role: "pastor"})
CREATE (tunde:Member {id: "mem_003", name: "Tunde Bakare", role: "leader"})
CREATE (adaeze:Member {id: "mem_004", name: "Adaeze Obi", role: "member"})
CREATE (halima:Member {id: "mem_008", name: "Halima Bello", role: "member"})
CREATE (ikenna:Member {id: "mem_009", name: "Ikenna Nnamdi", role: "member"})

// Groups
CREATE (choir:Group {id: "grp_001", name: "Choir", type: "choir"})
CREATE (youth:Group {id: "grp_002", name: "Youth Ministry", type: "youth"})
CREATE (prayer:Group {id: "grp_004", name: "Prayer Warriors", type: "department"})

// Church
CREATE (grace:Church {id: "church_001", name: "Grace Chapel Lagos"})
```

### Relationships

```cypher
// Membership
CREATE (emeka)-[:BELONGS_TO {since: date("2010-03-15")}]->(grace)
CREATE (tunde)-[:BELONGS_TO {since: date("2013-06-20")}]->(grace)
CREATE (adaeze)-[:BELONGS_TO {since: date("2016-09-05")}]->(grace)

// Group membership
CREATE (tunde)-[:LEADS]->(choir)
CREATE (adaeze)-[:MEMBER_OF]->(choir)
CREATE (halima)-[:MEMBER_OF]->(choir)
CREATE (adaeze)-[:LEADS]->(youth)
CREATE (ikenna)-[:MEMBER_OF]->(youth)
CREATE (emeka)-[:MEMBER_OF]->(prayer)

// Mentorship / discipleship
CREATE (emeka)-[:MENTORS {started: date("2015-01-01")}]->(tunde)
CREATE (tunde)-[:MENTORS {started: date("2018-06-01")}]->(adaeze)
CREATE (adaeze)-[:MENTORS {started: date("2022-01-15")}]->(halima)

// Family
CREATE (emeka)-[:FAMILY {relationship: "spouse"}]->(blessing:Member {id: "mem_002", name: "Blessing Adekunle"})
```

### Sample Queries

```cypher
// 1. Find Emeka's full discipleship chain (who he mentors, and who they mentor)
MATCH path = (emeka:Member {name: "Emeka Okafor"})-[:MENTORS*]->(mentee)
RETURN [node IN nodes(path) | node.name] AS discipleship_chain

// Result: ["Emeka Okafor", "Tunde Bakare", "Adaeze Obi", "Halima Bello"]

// 2. Find all members who share a group with Adaeze
MATCH (adaeze:Member {name: "Adaeze Obi"})-[:MEMBER_OF|LEADS]->(g:Group)<-[:MEMBER_OF|LEADS]-(peer)
RETURN DISTINCT peer.name AS shared_group_peer, g.name AS via_group

// 3. Shortest relationship path between two members
MATCH path = shortestPath(
  (emeka:Member {name: "Emeka Okafor"})-[*]-(halima:Member {name: "Halima Bello"})
)
RETURN path

// 4. Members who are not yet being mentored
MATCH (m:Member)
WHERE NOT (m)<-[:MENTORS]-()
  AND m.role = "member"
RETURN m.name AS unmentored_members
```

## Why a Graph Model Suits This Use Case

Discipleship and mentorship are inherently **recursive, variable-depth relationships**. In PostgreSQL, finding "everyone in Emeka's discipleship chain" requires a recursive CTE that is hard to read and slow as depth grows. In Neo4j, the same query is a single pattern match (`-[:MENTORS*]->`) that traverses the graph in milliseconds regardless of depth.

Group co-membership ("find me people Adaeze shares a group with") requires a many-to-many self-join through `group_members` in SQL. In the graph, it is a two-hop traversal.

## Architecture Position

The graph database would complement (not replace) the primary relational database. PostgreSQL remains the system of record for transactional data (donations, attendance logs). Neo4j holds the relationship graph, synchronised via event-driven updates when members join groups or mentorship relationships are recorded.
