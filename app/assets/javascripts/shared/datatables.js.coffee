dataTableActive = null;
dataTableInactive = null;
dataTableSuspened = null;
dataTableOther = null;

ready = ->
  $.extend($.fn.dataTable.defaults, {
    bSort: false
    autoWidth: false
    "dom" : "<'row p-top-xs'<'col-sm-6'l><'col-sm-3 col-sm-offset-3 text-right'f>><'row'<'col-sm-12'tr>><'row'<'col-sm-6'i><'col-sm-6'p>>",
    pageLength: 25,
    timeout: 120,
  })

  $.extend($.fn.dataTable.defaults.oLanguage, {
    "sProcessing": "<div class='dt-loading'><div>Traitement en cours...</div><img src='/img/loading.gif' /></div>"
    "sSearch": "<div class='input-group'> _INPUT_ <span class='input-group-addon'><em class='fa fa-search'></em></span></div>"
    "sLengthMenu": "Afficher _MENU_ &eacute;l&eacute;ments"
    "sInfo": "Affichage de l'&eacute;lement _START_ &agrave; _END_ sur _TOTAL_ &eacute;l&eacute;ments"
    "sInfoEmpty": "Affichage de l'&eacute;lement 0 &agrave; 0 sur 0 &eacute;l&eacute;ments"
    "sInfoFiltered": "(filtr&eacute; de _MAX_ &eacute;l&eacute;ments au total)"
    "sInfoPostFix": ""
    "sLoadingRecords": "Chargement en cours..."
    "sZeroRecords": "Aucun &eacute;l&eacute;ment &agrave; afficher"
    "sEmptyTable": "Aucune donnée disponible dans le tableau"
    "oPaginate":
      "sFirst": "<em class='fa fa-angle-double-left'></em>"
      "sPrevious": "<em class='fa fa-angle-left'></em>"
      "sNext": "<em class='fa fa-angle-right'></em>"
      "sLast": "<em class='fa fa-angle-double-right'></em>"
    "oAria":
      "sSortAscending": ": activer pour trier la colonne par ordre croissant"
      "sSortDescending": ": activer pour trier la colonne par ordre décroissant"
  })

  dataTableOther = $("table[data-datatable=true]").DataTable

  dataTableActive = $("table#userActiveTable").DataTable
    processing: true
    serverSide: true
    responsive: true
    stateSave: true
    columns: [
      {
        name: "lastname"
        responsivePriority: 1
      }
      {
        name: "firstname"
        responsivePriority: 6
      }
      {
        name: "email"
        responsivePriority: 5
      }
      {
        name: "start_at"
        responsivePriority: 4
      }
      {
        name: "commited"
        searchable: false
        responsivePriority: 2
      }
      {
        name: "actions"
        searchable: false
        orderable: false
        class: 'text-right'
        responsivePriority: 1
      }
    ]
    order: [ [3,'desc'] ]

  dataTableInactive = $("table#userInactiveTable").DataTable
    processing: true
    serverSide: true
    responsive: true
    stateSave: true
    columns: [
      {
        name: "lastname"
        responsivePriority: 1
      }
      {
        name: "firstname"
        responsivePriority: 6
      }
      {
        name: "email"
        responsivePriority: 5
      }
      {
        name: "actions"
        searchable: false
        orderable: false
        class: 'text-right'
        responsivePriority: 1
      }
    ]
    order: [ [1,'asc'] ]

  dataTableSuspened = $("table#userSuspendedTable").DataTable
    processing: true
    serverSide: true
    responsive: true
    stateSave: true
    columns: [
      {
        name: "lastname"
        responsivePriority: 1
      }
      {
        name: "firstname"
        responsivePriority: 6
      }
      {
        name: "email"
        responsivePriority: 5
      }
      {
        name: "start_at"
        responsivePriority: 4
      }
      {
        name: "commited"
        searchable: false
        responsivePriority: 2
      }
      {
        name: "actions"
        searchable: false
        orderable: false
        class: 'text-right'
        responsivePriority: 1
      }
    ]
    order: [ [3,'desc'] ]

$(document).ready ready