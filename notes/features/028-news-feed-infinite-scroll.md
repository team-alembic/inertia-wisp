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
    read_at: Option(String),
  )
}

pub type NewsFeed {
  NewsFeed(
    articles: List(ArticleWithReadStatus),
    meta: PaginationMeta,
    has_more: Bool,
    total_unread: Int,
    current_category: Option(ArticleCategory),
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
- Coordinates loading states

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

### Backend Modules

#### `examples/simple-demo/src/handlers/news.gleam`
- `news_feed/2` - Main feed handler with pagination
- `news_article/2` - Individual article handler
- Query parameter parsing for filters/pagination

#### `examples/simple-demo/src/news/props.gleam`
- `news_feed/3` - Factory for NewsFeed props
- `article_list/2` - Factory for article collections
- `pagination_meta/3` - Factory for pagination metadata

#### `examples/simple-demo/src/news/queries.gleam`
- `get_articles_paginated/5` - Main pagination query with user_id
- `get_articles_by_category/5` - Category filtering with user read status
- `mark_article_read/3` - Read tracking per user
- `get_article_by_id/3` - Individual article fetch with user read status
- `get_unread_count_for_user/2` - Count unread articles for specific user
- `get_user_read_status/3` - Check if user has read specific article

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
- [ ] Create article prop factories with read status
- [ ] Write unit tests for data layer including multi-user read tracking

### Phase 2: Backend Handlers
- [ ] Implement news_feed handler with MergeProp
- [ ] Implement individual article handler
- [ ] Add category filtering support
- [ ] Write integration tests for handlers

### Phase 3: Frontend Components
- [ ] Create ArticleCard component
- [ ] Create NewsFeed container component
- [ ] Implement infinite scroll logic
- [ ] Add loading states and error handling

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