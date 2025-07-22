# 028 - News Feed Infinite Scroll with MergeProp

## Product Level Requirements

### Business Objectives
- Increase user engagement through continuous content discovery
- Reduce page load times by loading content progressively
- Improve content consumption metrics (time on site, articles read per session)
- Enable efficient content delivery at scale

### Success Metrics
- **Engagement**: Average session duration increases by 25%
- **Consumption**: Articles read per session increases by 40%
- **Performance**: Initial page load time under 800ms
- **Retention**: Daily active users increase by 15%
- **Technical**: 95th percentile load time for additional content under 300ms

### Content Publisher Requirements
- Support 10,000+ articles with efficient pagination
- Category-based content organization
- Read/unread tracking for personalization
- SEO-friendly URLs for individual articles

## User Level Requirements

### User Motivations
- Discover relevant news content without manual navigation
- Consume content at their own pace without interruption
- Access new content as it becomes available
- Maintain reading context across sessions

### UX Affordances
- Smooth infinite scroll with no pagination clicks required
- Loading indicators that don't disrupt reading flow
- Clear visual hierarchy for article priority
- "Back to top" functionality for long feeds
- Responsive design across desktop/mobile
- Keyboard navigation support

### Interaction Patterns
- Scroll to load more content automatically
- Click article titles to read full content
- Visual indication of read/unread status
- Category filtering without losing scroll position

## Architectural Constraints

### Inertia.js Integration
- Must use MergeProp for infinite scroll data merging
- Leverage DeferredProp for performance optimization
- Follow existing handler patterns in `examples/simple-demo/src/handlers/`
- Enable future SSR compatibility

### Performance Requirements
- Database queries must be paginated efficiently
- Image loading must be lazy/progressive
- Client-side state must remain minimal
- Memory usage must not grow unbounded with scroll

### System Integration
- Use existing database schema patterns in `examples/simple-demo`
- Follow existing prop factory conventions
- Integrate with current routing structure
- Support existing authentication/authorization
- **Multi-user read tracking**: Articles have per-user read status via junction table

### Project Location
- **CRITICAL**: All implementation work must be done in `examples/simple-demo/` project
- Do NOT work in `examples/demo/` - it uses an older API version

### Read Status Design
- **Per-user tracking**: Each user has independent read/unread status for articles
- **Database design**: `article_reads` junction table with `(user_id, article_id, read_at)`
- **No global read status**: Articles themselves don't have `is_read` field
- **Query pattern**: JOIN articles with user-specific read status for feed display

## Implementation Design

### Domain Model

```gleam
pub type Article {
  Article(
    id: Int,
    title: String,
    summary: String,
    author: String,
    published_at: String,
    category: ArticleCategory,
    read_time: Int,
    image_url: Option(String),
  )
}

pub type ArticleRead {
  ArticleRead(
    user_id: Int,
    article_id: Int,
    read_at: String,
  )
}

pub type ArticleCategory {
  Technology
  Business
  Science
  Sports
  Entertainment
}

pub type ArticleWithReadStatus {
  ArticleWithReadStatus(
    article: Article,
    is_read: Bool,
    read_at: String,
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

pub type PaginationMeta {
  PaginationMeta(
    current_page: Int,
    per_page: Int,
    total_count: Int,
    last_page: Int,
  )
}

// Prop types for Inertia.js integration
pub type NewsProp {
  NewsFeed(NewsFeed)
  ArticleList(List(ArticleWithReadStatus))
  ArticleData(ArticleWithReadStatus)
  PaginationMeta(PaginationMeta)
  CategoryFilter(String)
  UnreadCount(Int)
}
```

### Workflows

#### Initial Feed Load
1. User navigates to `/news`
2. Backend loads first 20 articles
3. Returns NewsFeed with initial data + pagination meta
4. Frontend renders articles with infinite scroll listener

#### Infinite Scroll Load
1. User scrolls near bottom of feed
2. Frontend triggers Inertia visit with `merge` option
3. Backend loads next page of articles
4. MergeProp merges new articles with existing feed
5. Frontend updates scroll listener for next page

#### Category Filtering
1. User selects category filter
2. Frontend triggers new request with category parameter
3. Backend resets pagination and loads filtered articles
4. Frontend replaces feed (no merge) and resets scroll

### Pages

#### `/news` - Main News Feed
- Primary infinite scroll interface
- Category filtering sidebar
- Search functionality
- "Back to top" button

#### `/news/article/:id` - Individual Article
- Full article content
- Related articles suggestions
- Social sharing options
- "Back to feed" navigation

### Components

#### `NewsFeed.tsx`
- Main container component
- Manages infinite scroll logic
- Handles category filtering
- Coordinates client-side state

#### `ArticleCard.tsx`
- Individual article preview
- Read/unread visual states
- Author and metadata display
- Click to full article

#### `CategoryFilter.tsx`
- Category selection interface
- Active filter indication
- Clear filters option

#### `InfiniteScrollLoader.tsx`
- Loading indicator for new content
- Error state handling
- "Load more" manual trigger fallback

### Backend API Specification

#### `GET /news` - News Feed Endpoint (implemented)
**Query Parameters:**
- `page` (int, default: 1) - Page number for pagination
- `per_page` (int, default: 20, max: 100) - Articles per page
- `category` (string, optional) - Filter by category ("technology", "business", "science", "sports", "entertainment")

**Response Format:**
```json
{
  "component": "NewsFeed",
  "props": {
    "news_feed": {
      "articles": [
        {
          "article": {
            "id": 1,
            "title": "Article Title",
            "summary": "Article summary...",
            "author": "Author Name",
            "published_at": "2024-01-15T10:30:00Z",
            "category": "technology",
            "read_time": 5,
            "image_url": "https://example.com/image.jpg"
          },
          "is_read": false,
          "read_at": ""
        }
      ],
      "meta": {
        "current_page": 1,
        "per_page": 20,
        "total_count": 65,
        "last_page": 4
      },
      "has_more": true,
      "total_unread": 45,
      "current_category": "technology"
    }
  }
}
```

**MergeProp Configuration:**
- Uses `MergeProp` with `match_on: None, deep: False`
- Enables automatic merging for infinite scroll
- Frontend can trigger merge with `Inertia.get("/news?page=2", { preserveState: true, only: ["news_feed"] })`

#### `GET /news/article/:id` - Individual Article Endpoint (implemented)
**Response Format:**
```json
{
  "component": "Article",
  "props": {
    "article": {
      "article": { /* same article structure */ },
      "is_read": true,
      "read_at": "2024-01-15T10:30:00Z"
    }
  }
}
```

**Side Effects:**
- Automatically marks article as read for current user
- Updates `article_reads` table with read timestamp

### Backend Modules (implemented)

#### `examples/simple-demo/src/handlers/news.gleam`
- `news_feed/2` - Main feed handler with MergeProp and pagination
- `news_article/2` - Individual article handler with read tracking
- Query parameter parsing with validation (`get_pagination_params`, `get_category_filter`)
- Continuation-passing style for clean error handling (404 for invalid IDs)
- HTTP status codes: 200 (success), 404 (not found), 500 (server error)

#### `examples/simple-demo/src/news/props.gleam`
- `news_feed/1` - MergeProp factory for infinite scroll merging
- `article_list/1` - OptionalProp factory for expensive operations
- `article_data/1` - DefaultProp factory for single articles
- `pagination_meta/1` - DefaultProp factory for pagination metadata
- `category_filter/1` - DefaultProp factory for category filtering
- `unread_count/1` - DeferProp factory for expensive calculations
- `news_prop_to_json/1` - JSON encoding for all prop types

#### `examples/simple-demo/src/data/articles.gleam` (implemented)
- Multi-user read tracking via `article_reads` junction table
- 65 sample articles across all categories for testing
- Efficient pagination queries with user-specific read status
- Category filtering with proper SQL joins
- All database operations return proper `Result` types for error handling

### Frontend Integration Requirements

#### Infinite Scroll Implementation
- Use Inertia's `preserveState: true` option to maintain scroll position
- Include `only: ["news_feed"]` to fetch only news feed data
- Backend automatically merges new articles with existing feed via MergeProp
- Monitor `has_more` field to determine when to stop loading

#### Category Filtering Implementation  
- Reset pagination when changing categories (`page=1`)
- Use `preserveState: false` to replace entire feed (no merge)
- Update URL parameters to maintain filter state on refresh

#### Read Status Tracking
- Visual distinction between read/unread articles
- Automatic read marking when viewing individual articles
- Real-time unread count updates (via `total_unread` field)

#### Error Handling
- **Backend-driven error handling**: 404/500 errors redirect to Error component with `errors` prop
- **Frontend network errors**: Handle Inertia.js request failures and network connectivity issues  
- **React ErrorBoundary**: Catch implementation defects in React components

## Testing Plan

### TDD Unit Tests
- Article prop factory functions
- Pagination query logic
- Category filtering logic
- Read/unread state management
- MergeProp behavior with article lists

### Integration Tests (Local Dev)
- Full page load with initial articles
- Infinite scroll triggers next page load
- Category filtering resets and filters correctly
- Individual article navigation and back button
- Mobile responsive behavior

### Performance Tests (Staging)
- Load testing with 10,000+ articles
- Memory usage monitoring during extended scrolling
- Database query performance under load
- Image loading optimization verification

### Product Tests (Production)
- A/B testing of articles per page (15 vs 20 vs 25)
- User engagement metric tracking
- Content discovery pattern analysis
- Performance monitoring and alerting

## Implementation Tasks

### Phase 1: Core Data Layer
- [x] Create article database schema and seed data
- [x] Create article_reads junction table for per-user read tracking
- [x] Implement article queries with pagination and user read status
- [x] Create article prop factories with read status
- [x] Write unit tests for data layer including multi-user read tracking

### Phase 2: Backend Handlers
- [x] Implement news_feed handler with MergeProp
- [x] Implement individual article handler
- [x] Add category filtering support
- [x] Write integration tests for handlers

### Phase 3: Frontend Components
- [ ] Create ArticleCard component
- [ ] Create NewsFeed container component
- [ ] Implement infinite scroll logic
- [ ] Add error handling

### Phase 4: Advanced Features
- [ ] Add category filtering UI
- [ ] Implement read/unread tracking
- [ ] Add "back to top" functionality
- [ ] Optimize for mobile experience

### Phase 5: Performance & Polish
- [ ] Implement image lazy loading
- [ ] Add keyboard navigation support
- [ ] Performance optimization and testing
- [ ] Final UX polish and accessibility