from pydantic import BaseModel
from typing import List
from app.schemas.article_schema import NewsArticleResponse


class FeedResponse(BaseModel):
    articles: List[NewsArticleResponse]
    count: int
