import { A, Code, CodeBlock, H1, H2, Li, Notice, Ol, P, Strong } from '@/Components'
import dedent from 'dedent-js'

export const meta = {
  title: 'The protocol',
  links: [
    { url: '#html-responses', name: 'HTML responses' },
    { url: '#inertia-responses', name: 'Inertia responses' },
    { url: '#the-page-object', name: 'The page object' },
    { url: '#asset-versioning', name: 'Asset versioning' },
    { url: '#partial-reloads', name: 'Partial reloads' },
  ],
}

export default function () {
  return (
    <>
      <H1>The protocol</H1>
      <P>
        This page contains a detailed specification of the Inertia protocol. Be sure to read the{' '}
        <A href="/how-it-works">how it works</A> page first for a high-level overview.
      </P>
      <H2>HTML responses</H2>
      <P>
        The very first request to an Inertia app is just a regular, full-page browser request, with no special Inertia
        headers or data. For these requests, the server returns a full HTML document.
      </P>
      <P>
        This HTML response includes the site assets (CSS, JavaScript) as well as a root <Code>{'<div>'}</Code> in the
        page's body. The root <Code>{'<div>'}</Code> serves as a mounting point for the client-side app, and includes a{' '}
        <Code>data-page</Code> attribute with a JSON encoded <A href="#the-page-object">page object</A> for the initial
        page. Inertia uses this information to boot your client-side framework and display the initial page component.
      </P>
      <CodeBlock
        language="http"
        children={dedent`
          Request
          GET: http://example.com/events/80
          Accept: text/html, application/xhtml+xml

          Response
          HTTP/1.1 200 OK
          Content-Type: text/html; charset=utf-8

          <html>
          <head>
              <title>My app</title>
              <link href="/css/app.css" rel="stylesheet">
              <script src="/js/app.js" defer></script>
          </head>
          <body>
              <div id="app" data-page='{"component":"Event","props":{"event":{"id":80,"title":"Birthday party","start_date":"2019-06-02","description":"Come out and celebrate with us!"}},"url":"/events/80","version":"c32b8e4965f418ad16eaebba1d4e960f"}'></div>
          </body>
          </html>
        `}
      />
      <Notice>
        While the initial response is HTML, Inertia does not server-side render the JavaScript page components.
      </Notice>
      <H2>Inertia responses</H2>
      <P>
        Once the Inertia app has been booted, all subsequent requests to the site are made via XHR with a{' '}
        <Code>X-Inertia</Code> header set to <Code>true</Code>. This header indicates that the request is being made by
        Inertia and isn't a standard full-page visit.
      </P>
      <P>
        When the server detects the <Code>X-Inertia</Code> header, instead of responding with a full HTML document, it
        returns a JSON response with an encoded <A href="#the-page-object">page object</A>.
      </P>
      <CodeBlock
        language="http"
        children={dedent`
          Request
          GET: http://example.com/events/80
          Accept: text/html, application/xhtml+xml
          X-Requested-With: XMLHttpRequest
          X-Inertia: true
          X-Inertia-Version: 6b16b94d7c51cbe5b1fa42aac98241d5

          Response
          HTTP/1.1 200 OK
          Content-Type: application/json
          Vary: X-Inertia
          X-Inertia: true

          {
            "component": "Event",
            "props": {
              "event": {
                "id": 80,
                "title": "Birthday party",
                "start_date": "2019-06-02",
                "description": "Come out and celebrate with us!"
              }
            },
            "url": "/events/80",
            "version": "c32b8e4965f418ad16eaebba1d4e960f"
          }
        `}
      />
      <H2>The page object</H2>
      <P>
        Inertia shares data between the server and client via a page object. This object includes the necessary
        information required to render the page component, update the browser's history state, and track the site's
        asset version. The page object includes the following four properties:
      </P>
      <Ol>
        <Li>
          <Strong>component:</Strong> The name of the JavaScript page component.
        </Li>
        <Li>
          <Strong>props:</Strong> The page props (data).
        </Li>
        <Li>
          <Strong>url:</Strong> The page URL.
        </Li>
        <Li>
          <Strong>version:</Strong> The current asset version.
        </Li>
        <Li>
          <Strong>encryptHistory:</Strong> Whether or not to encrypt the current page's history state.
        </Li>
        <Li>
          <Strong>clearHistory:</Strong> Whether or not to clear any encrypted history state.
        </Li>
      </Ol>
      <P>
        On standard full page visits, the page object is JSON encoded into the <Code>data-page</Code> attribute in the
        root <Code>{'<div>'}</Code>. On Inertia visits, the page object is returned as the JSON payload.
      </P>
      <CodeBlock
        language="json"
        children={dedent`
          {
            "component": "Event",
            "props": {
              "event": {
                "id": 80,
                "title": "Birthday party",
                "start_date": "2019-06-02",
                "description": "Come out and celebrate with us!"
              }
            },
            "url": "/events/80",
            "version": "c32b8e4965f418ad16eaebba1d4e960f"
          }
        `}
      />
      <H2>Asset versioning</H2>
      <P>
        One common challenge with single-page apps is refreshing site assets when they've been changed. Inertia makes
        this easy by optionally tracking the current version of the site's assets. In the event that an asset changes,
        Inertia will automatically make a full-page visit instead of an XHR visit.
      </P>
      <P>
        The Inertia page object includes a <Code>version</Code> identifier. This version
        identifier is set server-side and can be a number, string, file hash, or any other value that represents the
        current "version" of your site's assets, as long as the value changes when the site's assets have been updated.
      </P>
      <P>
        Whenever an Inertia request is made, Inertia will include the current asset version in the{' '}
        <Code>X-Inertia-Version</Code> header. When the server receives the request, it compares the asset version
        provided in the <Code>X-Inertia-Version</Code> header with the current asset version. This is typically handled
        in the middleware layer of your server-side framework.
      </P>
      <P>
        If the asset versions are the same, the request simply continues as expected. However, if the asset versions are
        different, the server immediately returns a <Code>409 Conflict</Code> response, and includes the URL in a{' '}
        <Code>X-Inertia-Location</Code> header. This header is necessary, since server-side redirects may have occurred.
        This tells Inertia what the final intended destination URL is.
      </P>
      <P>
        Note, <Code>409 Conflict</Code> responses are only sent for <Code>GET</Code> requests, and not for{' '}
        <Code>POST/PUT/PATCH/DELETE</Code> requests. That said, they will be sent in the event that a <Code>GET</Code>{' '}
        redirect occurs after one of these requests.
      </P>
      <P>
        If "flash" session data exists when a <Code>409 Conflict</Code> response occurs, Inertia's server-side framework
        adapters will automatically reflash this data.
      </P>
      <CodeBlock
        language="http"
        children={dedent`
          Request
          GET: http://example.com/events/80
          Accept: text/html, application/xhtml+xml
          X-Requested-With: XMLHttpRequest
          X-Inertia: true
          X-Inertia-Version: 6b16b94d7c51cbe5b1fa42aac98241d5

          Response
          409: Conflict
          X-Inertia-Location: http://example.com/events/80
        `}
      />
      <P>
        You can read more about this on the <A href="/asset-versioning">asset versioning</A> page.
      </P>
      <H2>Partial reloads</H2>
      <P>
        When making Inertia requests, the partial reload option allows you to request a subset of the props (data) from
        the server on subsequent visits to the <em>same</em> page component. This can be a helpful performance
        optimization if it's acceptable that some page data becomes stale.
      </P>
      <P>
        When a partial reload request is made, Inertia includes two additional headers with the request:{' '}
        <Code>X-Inertia-Partial-Data</Code> and <Code>X-Inertia-Partial-Component</Code>.
      </P>
      <P>
        The <Code>X-Inertia-Partial-Data</Code> header is a comma separated list of the desired props (data) keys that
        should be returned.
      </P>
      <P>
        The <Code>X-Inertia-Partial-Component</Code> header includes the name of the component that is being partially
        reloaded. This is necessary, since partial reloads only work for requests made to the same page component. If
        the final destination is different for some reason (eg. the user was logged out and is now on the login page),
        then no partial reloading will occur.
      </P>
      <CodeBlock
        language="http"
        children={dedent`
          Request
          GET: http://example.com/events
          Accept: text/html, application/xhtml+xml
          X-Requested-With: XMLHttpRequest
          X-Inertia: true
          X-Inertia-Version: 6b16b94d7c51cbe5b1fa42aac98241d5
          X-Inertia-Partial-Data: events
          X-Inertia-Partial-Component: Events

          Response
          HTTP/1.1 200 OK
          Content-Type: application/json

          {
            "component": "Events",
            "props": {
              "events": [
                {
                  "id": 80,
                  "title": "Birthday party",
                  "start_date": "2019-06-02",
                  "description": "Come out and celebrate with us!"
                },
                {
                  "id": 81,
                  "title": "Breakfast meet-up",
                  "start_date": "2019-06-03",
                  "description": "A fun breakfast meet-up."
                }
              ]
            },
            "url": "/events",
            "version": "c32b8e4965f418ad16eaebba1d4e960f"
          }
        `}
      />
    </>
  )
}
