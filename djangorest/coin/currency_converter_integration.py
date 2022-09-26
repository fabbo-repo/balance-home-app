import logging

from datetime import timedelta

from django.utils.timezone import now

from movies.models import Genre, SearchTerm, Movie

from currency_converter.django_client import get_converter_from_db

logger = logging.getLogger(__name__)

def covert(coin_from, coin_to, amount):
    # TODO
    pass

def search_and_save(search):
    """
    Perform a search for search_term against the API, but only
    if it hasn't been searched in the past 24 hours. Save
    each result to the local DB as a partial record.
    """
    # Replace multiple spaces with single spaces, and lowercase the search
    normalized_search_term = re.sub(r"\s+", " ", search.lower())
    search_term, created = SearchTerm.objects.get_or_create(term=normalized_search_term)
    if not created and (search_term.last_search > now() - timedelta(days=1)):
        # Don't search as it has been searched recently
        logger.warning( "Search for '%s' was performed in the past 24 hours so not searching again.",
            normalized_search_term,
        )
        return
    omdb_client = get_client_from_settings()
    for omdb_movie in omdb_client.search(search):
        logger.info("Saving movie: '%s' / '%s'",
            omdb_movie.title, omdb_movie.imdb_id)
        
        movie, created = Movie.objects.get_or_create(
            imdb_id=omdb_movie.imdb_id,
            defaults={
                "title": omdb_movie.title,
                "year": omdb_movie.year,
            },
        )
        if created:
            logger.info("Movie created: '%s'", movie.title)
    search_term.save()