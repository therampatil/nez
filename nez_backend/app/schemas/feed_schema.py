from pydantic import BaseModel
from typing import List
from app.schemas.article_schema import ArticleResponse


class FeedResponse(BaseModel):
    articles: List[ArticleResponse]
    count: int
