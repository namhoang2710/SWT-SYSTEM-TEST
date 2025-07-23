export function buildUrl(
    template: string,
    pathParams?: Record<string, string | number>
  ): string {
    let url = template;
  
    if (pathParams) {
      Object.entries(pathParams).forEach(([k, v]) => {
        // Create a global RegExp that matches all `:paramName` occurrences
        // The “g” flag means “replace all matches”
        const pattern = new RegExp(`:${k}`, 'g');
        url = url.replace(pattern, encodeURIComponent(String(v)));
      });
    }
  
    return url;
  }
  