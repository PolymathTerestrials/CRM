<?php

use Slim\Http\Request;
use Slim\Http\Response;
use ChurchCRM\Service\CalendarService;
use ChurchCRM\CalendarQuery;
use ChurchCRM\EventQuery;

$app->group('/calendars', function () {
    $this->get('','getCalendars');
    $this->get('/','getCalendars');
    $this->get('/{id}/events', 'getEvents');
});

function getCalendars(Request $request, Response $response, array $p_args ) {
    $params = $request->getQueryParams();
    $Calendars = CalendarQuery::create()
            ->find();
    return $response->withJson($Calendars->toJSON());
}


function getEvents(Request $request, Response $response, array $p_args ) {
  $Calendar = CalendarQuery::create()->findOneById($p_args['id']);
  if ($Calendar) {
    $Events = EventQuery::create()
          ->filterByCalendar($Calendar)
          ->find();
    return $response->withJson($Events->toJSON());
  }

}