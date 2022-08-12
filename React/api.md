# API
```react
    const getMovie = async () => {
        const json = await(
            await fetch(`https://yts.mx/api/v2/movie_details.json?movie_id=${id}`)
        ).json();
        console.log(json);
    };
    useEffect(() => {
        getMovie();
    }, []);
```
```react
    const getMovies = async() => {
      const json = await (
        await fetch(
         'https://yts.mx/api/v2/list_movies.json?minimum_rating=8.8&sort_by=year'
       )
       ).json(); 
```
```react
const API_END_POINT = "https://uikt6pohhh.execute-api.ap-northeast-2.amazonaws.com/dev";

export const request = async (url, options={}) => {
    try {
        const fullUrl = `${API_END_POINT}${url}`;
        const response = await fetch(fullUrl, options);
        if(response.ok) {
            const json = await response.json();
            return json;
        }
        throw new Error('API 통신 실패');
    }catch(e) {
        alert(e.message);
    }
}
```
