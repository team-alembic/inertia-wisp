import gleam/dynamic/decode
import gleam/list
import gleam/option
import gleam/result

import sqlight.{type Connection}

// ===== DOMAIN TYPES =====

pub type ArticleCategory {
  Technology
  Business
  Science
  Sports
  Entertainment
}

pub fn article_category_to_string(category: ArticleCategory) -> String {
  case category {
    Technology -> "technology"
    Business -> "business"
    Science -> "science"
    Sports -> "sports"
    Entertainment -> "entertainment"
  }
}

pub fn string_to_article_category(
  category_str: String,
) -> Result(ArticleCategory, String) {
  case category_str {
    "technology" -> Ok(Technology)
    "business" -> Ok(Business)
    "science" -> Ok(Science)
    "sports" -> Ok(Sports)
    "entertainment" -> Ok(Entertainment)
    _ -> Error("Invalid category: " <> category_str)
  }
}

pub type Article {
  Article(
    id: Int,
    title: String,
    summary: String,
    author: String,
    published_at: String,
    category: ArticleCategory,
    read_time: Int,
    image_url: String,
  )
}

pub type ArticleRead {
  ArticleRead(user_id: Int, article_id: Int, read_at: String)
}

pub type ArticleWithReadStatus {
  ArticleWithReadStatus(article: Article, is_read: Bool, read_at: String)
}

pub type PaginationMeta {
  PaginationMeta(
    current_page: Int,
    per_page: Int,
    total_count: Int,
    last_page: Int,
  )
}

pub type NewsFeed {
  NewsFeed(
    articles: List(ArticleWithReadStatus),
    meta: PaginationMeta,
    has_more: Bool,
    total_unread: Int,
    current_category: String,
  )
}

// ===== DATABASE FUNCTIONS =====

fn article_with_read_status_decoder() {
  use article_id <- decode.field(0, decode.int)
  use title <- decode.field(1, decode.string)
  use summary <- decode.field(2, decode.string)
  use author <- decode.field(3, decode.string)
  use published_at <- decode.field(4, decode.string)
  use category_str <- decode.field(5, decode.string)
  use read_time <- decode.field(6, decode.int)
  use image_url <- decode.field(7, decode.string)
  use read_at <- decode.field(8, decode.optional(decode.string))

  use category <- decode.then(case string_to_article_category(category_str) {
    Ok(cat) -> decode.success(cat)
    Error(msg) ->
      decode.failure(Technology, "Invalid category in database: " <> msg)
  })

  let article =
    Article(
      id: article_id,
      title: title,
      summary: summary,
      author: author,
      published_at: published_at,
      category: category,
      read_time: read_time,
      image_url: image_url,
    )

  decode.success(
    ArticleWithReadStatus(
      article: article,
      is_read: case read_at {
        option.Some(_) -> True
        option.None -> False
      },
      read_at: case read_at {
        option.Some(timestamp) -> timestamp
        option.None -> ""
      },
    ),
  )
}

pub fn create_articles_table(db: Connection) -> Result(Nil, sqlight.Error) {
  let sql =
    "
    CREATE TABLE IF NOT EXISTS articles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      summary TEXT NOT NULL,
      author TEXT NOT NULL,
      published_at TEXT NOT NULL,
      category TEXT NOT NULL,
      read_time INTEGER NOT NULL,
      image_url TEXT NOT NULL
    )
    "

  sqlight.exec(sql, db)
}

pub fn create_article_reads_table(db: Connection) -> Result(Nil, sqlight.Error) {
  let sql =
    "
    CREATE TABLE IF NOT EXISTS article_reads (
      user_id INTEGER NOT NULL,
      article_id INTEGER NOT NULL,
      read_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (user_id, article_id),
      FOREIGN KEY (article_id) REFERENCES articles (id) ON DELETE CASCADE
    )
    "

  sqlight.exec(sql, db)
}

pub fn init_sample_data(db: Connection) -> Result(Nil, sqlight.Error) {
  let sql =
    "
    INSERT INTO articles (title, summary, author, published_at, category, read_time, image_url) VALUES
    ('Breaking: New AI Framework Released', 'Revolutionary machine learning framework promises 10x performance improvements', 'Sarah Chen', '2024-01-15T10:30:00Z', 'technology', 5, 'https://images.unsplash.com/photo-1677442136019-21780ecad995'),
    ('Market Analysis: Tech Stocks Surge', 'Technology sector sees unprecedented growth amid AI boom', 'Michael Rodriguez', '2024-01-15T09:15:00Z', 'business', 3, 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3'),
    ('Scientists Discover New Quantum State', 'Breakthrough in quantum physics could revolutionize computing', 'Dr. Emily Watson', '2024-01-15T08:45:00Z', 'science', 7, 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb'),
    ('Championship Finals This Weekend', 'Two powerhouse teams prepare for the ultimate showdown', 'Jake Thompson', '2024-01-15T07:20:00Z', 'sports', 4, 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211'),
    ('New Streaming Series Breaks Records', 'Fantasy epic becomes most-watched premiere in platform history', 'Lisa Park', '2024-01-15T06:00:00Z', 'entertainment', 6, 'https://images.unsplash.com/photo-1489599577372-f4f4109e3e62'),
    ('Open Source AI Model Challenges Giants', 'Community-driven project rivals commercial alternatives', 'Alex Kumar', '2024-01-14T22:30:00Z', 'technology', 8, 'https://images.unsplash.com/photo-1555949963-aa79dcee981c'),
    ('Startup Funding Reaches New Heights', 'Venture capital investments in AI startups hit record levels', 'David Kim', '2024-01-14T21:15:00Z', 'business', 4, 'https://images.unsplash.com/photo-1559136555-9303baea8ebd'),
    ('Climate Change Research Shows Progress', 'New carbon capture technology shows promising results', 'Dr. Maria Santos', '2024-01-14T20:45:00Z', 'science', 6, 'https://images.unsplash.com/photo-1569163139394-de4e4f43e4e3'),
    ('Rookie Sensation Takes League by Storm', 'Young athlete breaks multiple records in debut season', 'Tom Wilson', '2024-01-14T19:30:00Z', 'sports', 5, 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b'),
    ('Award Season Predictions', 'Critics weigh in on this year most anticipated nominations', 'Rachel Green', '2024-01-14T18:00:00Z', 'entertainment', 3, 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1'),
    ('Cybersecurity Threats on the Rise', 'New malware family targets enterprise infrastructure', 'Chris Lee', '2024-01-14T16:45:00Z', 'technology', 7, 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b'),
    ('Economic Outlook: Mixed Signals', 'Economists debate inflation trends and market stability', 'Jennifer Martinez', '2024-01-14T15:30:00Z', 'business', 5, 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f'),
    ('Space Mission Launches Successfully', 'International collaboration sends probe to outer planets', 'Dr. Robert Chang', '2024-01-14T14:15:00Z', 'science', 8, 'https://images.unsplash.com/photo-1446776877081-d282a0f896e2'),
    ('Trade Deadline Shakeups Expected', 'Teams prepare for major roster changes ahead of deadline', 'Kevin Brown', '2024-01-14T13:00:00Z', 'sports', 4, 'https://images.unsplash.com/photo-1579952363873-27d3bfad9c0d'),
    ('Documentary Wins International Acclaim', 'Environmental film receives standing ovation at festival', 'Anna Davis', '2024-01-14T11:45:00Z', 'entertainment', 6, 'https://images.unsplash.com/photo-1485846234645-a62644f84728'),
    ('Blockchain Innovation in Healthcare', 'Medical records system promises enhanced security and privacy', 'Mark Johnson', '2024-01-14T10:30:00Z', 'technology', 9, 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56'),
    ('Merger Creates Industry Giant', 'Two major corporations announce billion-dollar deal', 'Susan White', '2024-01-14T09:15:00Z', 'business', 6, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d'),
    ('Gene Therapy Shows Promise', 'Clinical trials demonstrate effectiveness against rare diseases', 'Dr. James Miller', '2024-01-14T08:00:00Z', 'science', 10, 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158'),
    ('Olympic Preparations Underway', 'Athletes fine-tune training for upcoming games', 'Michelle Taylor', '2024-01-13T22:45:00Z', 'sports', 5, 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211'),
    ('Virtual Reality Concert Revolution', 'Artists embrace new technology for immersive performances', 'Brian Clark', '2024-01-13T21:30:00Z', 'entertainment', 7, 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f'),
    ('Machine Learning Breakthrough', 'Researchers develop faster training algorithms for neural networks', 'Dr. Patricia Wong', '2024-01-13T20:15:00Z', 'technology', 6, 'https://images.unsplash.com/photo-1518709268805-4e9042af2176'),
    ('Global Markets React to Rate Changes', 'Central banks coordinate response to inflation concerns', 'Robert Taylor', '2024-01-13T19:00:00Z', 'business', 4, 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44'),
    ('Deep Ocean Discovery', 'Marine biologists find new species in the Mariana Trench', 'Dr. Sarah Mitchell', '2024-01-13T17:45:00Z', 'science', 8, 'https://images.unsplash.com/photo-1559827260-dc66d52bef19'),
    ('Basketball Season Heats Up', 'Top teams vie for playoff positions in final stretch', 'Marcus Johnson', '2024-01-13T16:30:00Z', 'sports', 3, 'https://images.unsplash.com/photo-1546519638-68e109498ffc'),
    ('Film Festival Announces Winners', 'Independent cinema takes center stage at annual awards', 'Emma Rodriguez', '2024-01-13T15:15:00Z', 'entertainment', 5, 'https://images.unsplash.com/photo-1489599577372-f4f4109e3e62'),
    ('Cloud Computing Evolution', 'Edge computing transforms how we process data', 'Kevin Park', '2024-01-13T14:00:00Z', 'technology', 7, 'https://images.unsplash.com/photo-1451187580459-43490279c0fa'),
    ('Sustainable Energy Investments', 'Green technology funding reaches all-time high', 'Lisa Chen', '2024-01-13T12:45:00Z', 'business', 5, 'https://images.unsplash.com/photo-1466611653911-95081537e5b7'),
    ('Antarctic Research Reveals Climate Data', 'Ice core analysis provides new insights into global warming', 'Dr. Michael Brown', '2024-01-13T11:30:00Z', 'science', 9, 'https://images.unsplash.com/photo-1578662996442-48f60103fc96'),
    ('Soccer World Cup Qualifiers', 'National teams battle for spots in next tournament', 'Carlos Martinez', '2024-01-13T10:15:00Z', 'sports', 4, 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d'),
    ('Streaming Wars Intensify', 'New platforms challenge established entertainment giants', 'Amanda White', '2024-01-13T09:00:00Z', 'entertainment', 6, 'https://images.unsplash.com/photo-1522869635100-9f4c5e86aa37'),
    ('Quantum Computing Milestone', 'IBM achieves new record for quantum error correction', 'Dr. James Liu', '2024-01-13T07:45:00Z', 'technology', 8, 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb'),
    ('Cryptocurrency Market Analysis', 'Digital assets show resilience amid regulatory uncertainty', 'Thomas Anderson', '2024-01-13T06:30:00Z', 'business', 5, 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0'),
    ('Medical AI Breakthrough', 'Artificial intelligence improves cancer detection accuracy', 'Dr. Jennifer Davis', '2024-01-13T05:15:00Z', 'science', 7, 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56'),
    ('Tennis Championship Update', 'Rising stars challenge veteran players in grand slam', 'Maria Garcia', '2024-01-13T04:00:00Z', 'sports', 4, 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8'),
    ('Gaming Industry Evolution', 'Virtual reality gaming reaches mainstream adoption', 'Alex Thompson', '2024-01-13T02:45:00Z', 'entertainment', 6, 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f'),
    ('Robotics in Manufacturing', 'Automated systems increase production efficiency by 40%', 'Dr. Susan Kim', '2024-01-13T01:30:00Z', 'technology', 5, 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e'),
    ('Supply Chain Innovation', 'Blockchain technology improves logistics transparency', 'Daniel Wilson', '2024-01-13T00:15:00Z', 'business', 7, 'https://images.unsplash.com/photo-1586953208448-b95a79798f07'),
    ('Renewable Energy Storage', 'Battery technology advances enable grid-scale solutions', 'Dr. Laura Martinez', '2024-01-12T23:00:00Z', 'science', 8, 'https://images.unsplash.com/photo-1466611653911-95081537e5b7'),
    ('Winter Olympics Training', 'Athletes prepare for competition with cutting-edge techniques', 'Chris Johnson', '2024-01-12T21:45:00Z', 'sports', 5, 'https://images.unsplash.com/photo-1578662996442-48f60103fc96'),
    ('Concert Technology Revolution', 'Holographic performances blur reality and virtual worlds', 'Rachel Green', '2024-01-12T20:30:00Z', 'entertainment', 6, 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f'),
    ('5G Network Expansion', 'Ultra-fast connectivity reaches rural communities', 'Mike Chen', '2024-01-12T19:15:00Z', 'technology', 4, 'https://images.unsplash.com/photo-1451187580459-43490279c0fa'),
    ('E-commerce Growth Trends', 'Online retail continues post-pandemic expansion', 'Janet Taylor', '2024-01-12T18:00:00Z', 'business', 5, 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d'),
    ('Space Telescope Discoveries', 'Webb telescope reveals ancient galaxies and cosmic mysteries', 'Dr. Robert Chang', '2024-01-12T16:45:00Z', 'science', 9, 'https://images.unsplash.com/photo-1446776877081-d282a0f896e2'),
    ('Professional Golf Update', 'Young talents emerge in major tournament rankings', 'Steve Miller', '2024-01-12T15:30:00Z', 'sports', 3, 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b'),
    ('Streaming Content Trends', 'International productions gain global audience appeal', 'Lisa Park', '2024-01-12T14:15:00Z', 'entertainment', 6, 'https://images.unsplash.com/photo-1489599577372-f4f4109e3e62'),
    ('IoT Security Advances', 'New protocols protect connected devices from cyber threats', 'David Kim', '2024-01-12T13:00:00Z', 'technology', 7, 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b'),
    ('Fintech Innovation Wave', 'Digital banking solutions transform financial services', 'Sarah Rodriguez', '2024-01-12T11:45:00Z', 'business', 5, 'https://images.unsplash.com/photo-1563013544-824ae1b704d3'),
    ('Neuroscience Breakthrough', 'Brain-computer interfaces show promise for paralysis treatment', 'Dr. Emily Watson', '2024-01-12T10:30:00Z', 'science', 8, 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56'),
    ('Marathon Training Science', 'Sports medicine advances help runners optimize performance', 'Tom Wilson', '2024-01-12T09:15:00Z', 'sports', 6, 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b'),
    ('Digital Art Revolution', 'NFTs and blockchain transform creative industry economics', 'Anna Davis', '2024-01-12T08:00:00Z', 'entertainment', 7, 'https://images.unsplash.com/photo-1485846234645-a62644f84728'),
    ('Autonomous Vehicle Progress', 'Self-driving cars advance toward commercial deployment', 'Alex Kumar', '2024-01-12T06:45:00Z', 'technology', 6, 'https://images.unsplash.com/photo-1555949963-aa79dcee981c'),
    ('Green Finance Growth', 'ESG investing becomes mainstream for institutional funds', 'Michael Rodriguez', '2024-01-12T05:30:00Z', 'business', 5, 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3'),
    ('Climate Modeling Advances', 'Supercomputers improve weather prediction accuracy', 'Dr. Maria Santos', '2024-01-12T04:15:00Z', 'science', 8, 'https://images.unsplash.com/photo-1569163139394-de4e4f43e4e3'),
    ('Esports Championship Series', 'Competitive gaming reaches new viewership records', 'Jake Thompson', '2024-01-12T03:00:00Z', 'sports', 4, 'https://images.unsplash.com/photo-1542751371-adc38448a05e'),
    ('Podcast Industry Boom', 'Audio content platforms attract major celebrity partnerships', 'Brian Clark', '2024-01-12T01:45:00Z', 'entertainment', 5, 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f'),
    ('Edge AI Computing', 'Machine learning models run efficiently on mobile devices', 'Sarah Chen', '2024-01-12T00:30:00Z', 'technology', 7, 'https://images.unsplash.com/photo-1677442136019-21780ecad995'),
    ('Digital Transformation ROI', 'Companies report significant returns on technology investments', 'Jennifer Martinez', '2024-01-11T23:15:00Z', 'business', 6, 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f'),
    ('Synthetic Biology Applications', 'Engineered organisms address environmental challenges', 'Dr. James Miller', '2024-01-11T22:00:00Z', 'science', 9, 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158'),
    ('Paralympic Innovations', 'Adaptive sports technology enhances athlete performance', 'Michelle Taylor', '2024-01-11T20:45:00Z', 'sports', 5, 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211'),
    ('Immersive Theater Experience', 'Virtual reality transforms live performance venues', 'Rachel Green', '2024-01-11T19:30:00Z', 'entertainment', 6, 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1'),
    ('Smart City Infrastructure', 'IoT sensors optimize urban traffic and energy systems', 'Chris Lee', '2024-01-11T18:15:00Z', 'technology', 8, 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b'),
    ('Sustainable Business Models', 'Circular economy principles drive corporate strategy changes', 'Susan White', '2024-01-11T17:00:00Z', 'business', 7, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d'),
    ('Precision Medicine Advances', 'Genetic testing enables personalized treatment protocols', 'Dr. Robert Chang', '2024-01-11T15:45:00Z', 'science', 10, 'https://images.unsplash.com/photo-1446776877081-d282a0f896e2'),
    ('Extreme Sports Safety', 'New equipment technology reduces injury rates significantly', 'Kevin Brown', '2024-01-11T14:30:00Z', 'sports', 4, 'https://images.unsplash.com/photo-1579952363873-27d3bfad9c0d'),
    ('Social Media Evolution', 'Decentralized platforms challenge traditional network models', 'Emma Rodriguez', '2024-01-11T13:15:00Z', 'entertainment', 5, 'https://images.unsplash.com/photo-1489599577372-f4f4109e3e62')
    "

  sqlight.exec(sql, db)
}

pub fn get_articles_paginated(
  db: Connection,
  user_id: Int,
  page: Int,
  per_page: Int,
  category: String,
) -> Result(List(ArticleWithReadStatus), sqlight.Error) {
  let offset = { page - 1 } * per_page

  let base_sql =
    "
    SELECT a.id, a.title, a.summary, a.author, a.published_at, a.category, a.read_time, a.image_url, ar.read_at
    FROM articles a
    LEFT JOIN article_reads ar ON a.id = ar.article_id AND ar.user_id = ?
  "

  let #(where_clause, category_params) = case category {
    "all" -> #("", [])
    _ -> #("WHERE a.category = ?", [sqlight.text(category)])
  }

  let sql = base_sql <> where_clause <> "
    ORDER BY a.published_at DESC
    LIMIT ? OFFSET ?
  "

  let params =
    [sqlight.int(user_id)]
    |> list.append(category_params)
    |> list.append([sqlight.int(per_page), sqlight.int(offset)])

  sqlight.query(
    sql,
    on: db,
    with: params,
    expecting: article_with_read_status_decoder(),
  )
}

pub fn get_total_article_count(
  db: Connection,
  category: String,
) -> Result(Int, sqlight.Error) {
  let base_sql = "SELECT COUNT(*) FROM articles"

  let #(where_clause, params) = case category {
    "all" -> #("", [])
    _ -> #(" WHERE category = ?", [sqlight.text(category)])
  }

  let sql = base_sql <> where_clause

  let decoder = decode.at([0], decode.int)
  use rows <- result.try(sqlight.query(
    sql,
    on: db,
    with: params,
    expecting: decoder,
  ))
  case rows {
    [count] -> Ok(count)
    _ -> Ok(0)
  }
}

pub fn get_unread_count_for_user(
  db: Connection,
  user_id: Int,
) -> Result(Int, sqlight.Error) {
  let sql =
    "
    SELECT COUNT(*)
    FROM articles a
    LEFT JOIN article_reads ar ON a.id = ar.article_id AND ar.user_id = ?
    WHERE ar.article_id IS NULL
  "
  let decoder = decode.at([0], decode.int)
  use rows <- result.try(sqlight.query(
    sql,
    on: db,
    with: [sqlight.int(user_id)],
    expecting: decoder,
  ))
  case rows {
    [count] -> Ok(count)
    _ -> Ok(0)
  }
}

pub fn mark_article_read(
  db: Connection,
  user_id: Int,
  article_id: Int,
) -> Result(Nil, sqlight.Error) {
  let sql =
    "INSERT OR REPLACE INTO article_reads (user_id, article_id) VALUES (?, ?)"
  let decoder = decode.success(Nil)
  use _ <- result.try(sqlight.query(
    sql,
    on: db,
    with: [sqlight.int(user_id), sqlight.int(article_id)],
    expecting: decoder,
  ))
  Ok(Nil)
}

pub fn find_article_by_id(
  db: Connection,
  user_id: Int,
  article_id: Int,
) -> Result(ArticleWithReadStatus, sqlight.Error) {
  let sql =
    "
    SELECT a.id, a.title, a.summary, a.author, a.published_at, a.category, a.read_time, a.image_url, ar.read_at
    FROM articles a
    LEFT JOIN article_reads ar ON a.id = ar.article_id AND ar.user_id = ?
    WHERE a.id = ?
  "

  use rows <- result.try(sqlight.query(
    sql,
    on: db,
    with: [sqlight.int(user_id), sqlight.int(article_id)],
    expecting: article_with_read_status_decoder(),
  ))
  case rows {
    [article] -> Ok(article)
    [] ->
      Error(sqlight.SqlightError(
        code: sqlight.GenericError,
        message: "Article not found",
        offset: -1,
      ))
    _ ->
      Error(sqlight.SqlightError(
        code: sqlight.GenericError,
        message: "Multiple articles found",
        offset: -1,
      ))
  }
}

pub fn get_user_read_status(
  db: Connection,
  user_id: Int,
  article_id: Int,
) -> Result(Bool, sqlight.Error) {
  let sql = "
    SELECT 1 FROM article_reads
    WHERE user_id = ? AND article_id = ?
  "

  let decoder = decode.at([0], decode.int)
  use rows <- result.try(sqlight.query(
    sql,
    on: db,
    with: [sqlight.int(user_id), sqlight.int(article_id)],
    expecting: decoder,
  ))
  case rows {
    [_] -> Ok(True)
    [] -> Ok(False)
    _ -> Ok(False)
  }
}
