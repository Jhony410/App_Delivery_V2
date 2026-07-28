import '../../features/clientes/data/models/cliente.dart';
import '../../features/configuracion/data/models/configuracion_operativa.dart';
import '../../features/dashboard/data/models/resumen_operativo.dart';
import '../../features/negocios/data/models/negocio.dart';
import '../../features/pagos/data/models/liquidacion.dart';
import '../../features/pedidos/data/models/pedido.dart';
import '../../features/promociones/data/models/promocion.dart';
import '../../features/reportes/data/models/reporte_mensual.dart';
import '../../features/repartidores/data/models/repartidor.dart';
import '../models/estado_negocio.dart';
import '../models/estado_pedido.dart';
import '../models/estado_repartidor.dart';

/// Almacén en memoria con los datos de ejemplo del diseño (Puno y Melgar).
///
/// Todos los repositorios mock leen y escriben aquí, de modo que una
/// reasignación hecha desde Pedidos también se ve en Mapa, en la ficha del
/// repartidor y en Soporte al negocio. Al conectar Firebase, cada repositorio
/// cambia su fuente sin que la interfaz se entere.
class DelyMockStore {
  DelyMockStore._();

  static final DelyMockStore instance = DelyMockStore._();

  /// Momento que fija el diseño en la barra superior de todos los frames.
  static const String fechaPanel = 'Lun 27 jul';
  static const String horaPanel = '14:32';

  /// Operadora con la sesión abierta (avatar «JT» del diseño).
  static const String operadorNombre = 'Julia Torres';
  static const String operadorRol = 'Operaciones';
  static const String operadorCorreo = 'julia@delypuno.pe';
  static const String versionSistema = 'v2.4';

  // ── Pedidos ────────────────────────────────────────────────────────────
  late List<Pedido> pedidos = [
    const Pedido(
      id: '#A-2485',
      negocio: 'Pollería El Cholo',
      negocioDireccion: 'Jr. Puno 214',
      cliente: 'Luis Mamani',
      clienteDireccion: 'Jr. Tacna 88',
      estado: EstadoPedido.preparando,
      hora: '14:18',
      repartidorId: 'rep-01',
      repartidor: 'Rubén Mamani',
      repartidorCalificacion: 4.9,
      repartidorDistanciaKm: 1.2,
      monto: 42,
      emojiNegocio: '🍗',
      zona: 'Centro',
      etaMinutos: 6,
      tiempoMinutos: 4,
      items: [
        ItemPedido(cantidad: 1, nombre: 'Pollo entero', precio: 55),
        ItemPedido(cantidad: 1, nombre: 'Chaufa de pollo', precio: 14),
      ],
      historial: [
        EventoPedido(
          titulo: 'Pedido aceptado por el negocio',
          hora: '14:19',
          origen: 'automático',
        ),
        EventoPedido(
          titulo: 'Repartidor asignado · Rubén M.',
          hora: '14:21',
          origen: 'sistema',
        ),
        EventoPedido(
          titulo: 'En preparación',
          hora: '14:22',
          origen: 'en curso',
          enCurso: true,
        ),
      ],
    ),
    const Pedido(
      id: '#A-2484',
      negocio: 'Botica Salud+',
      negocioDireccion: 'Jr. Tacna 402',
      cliente: 'Ana Quispe',
      clienteDireccion: 'Jr. Deustua 137',
      estado: EstadoPedido.enCamino,
      hora: '14:06',
      repartidorId: 'rep-02',
      repartidor: 'Pedro Cutipa',
      repartidorCalificacion: 4.8,
      repartidorDistanciaKm: 0.9,
      monto: 28,
      emojiNegocio: '💊',
      zona: 'Bellavista',
      tiempoMinutos: 14,
      distanciaKm: 1.8,
      etaMinutos: 6,
      items: [
        ItemPedido(cantidad: 2, nombre: 'Paracetamol 500 mg', precio: 9),
        ItemPedido(cantidad: 1, nombre: 'Alcohol en gel 250 ml', precio: 10),
      ],
      historial: [
        EventoPedido(
          titulo: 'Pedido aceptado por el negocio',
          hora: '14:07',
          origen: 'automático',
        ),
        EventoPedido(
          titulo: 'Repartidor asignado · Pedro C.',
          hora: '14:09',
          origen: 'sistema',
        ),
        EventoPedido(
          titulo: 'Pedido recogido',
          hora: '14:18',
          origen: 'CHASQUI',
        ),
        EventoPedido(
          titulo: 'En camino al cliente',
          hora: '14:19',
          origen: 'en curso',
          enCurso: true,
        ),
      ],
    ),
    const Pedido(
      id: '#A-2483',
      negocio: 'Chifa Titicaca',
      negocioDireccion: 'Jr. Arequipa 55',
      cliente: 'Rosa Huamán',
      clienteDireccion: 'Jr. Lima 320',
      estado: EstadoPedido.buscandoRepartidor,
      hora: '14:24',
      monto: 55,
      emojiNegocio: '🥡',
      zona: 'Centro',
      tiempoMinutos: 8,
      items: [
        ItemPedido(cantidad: 2, nombre: 'Arroz chaufa especial', precio: 22),
        ItemPedido(cantidad: 1, nombre: 'Sopa wantán', precio: 16),
      ],
      historial: [
        EventoPedido(
          titulo: 'Pedido aceptado por el negocio',
          hora: '14:25',
          origen: 'automático',
        ),
        EventoPedido(
          titulo: 'Buscando repartidor',
          hora: '14:26',
          origen: 'en curso',
          enCurso: true,
        ),
      ],
    ),
    const Pedido(
      id: '#A-2482',
      negocio: 'Café del Lago',
      negocioDireccion: 'Jr. Libertad 190',
      cliente: 'Carlos Apaza',
      clienteDireccion: 'Av. El Sol 640',
      estado: EstadoPedido.entregado,
      hora: '13:41',
      repartidorId: 'rep-04',
      repartidor: 'Nilda Ruiz',
      repartidorCalificacion: 4.6,
      monto: 30,
      emojiNegocio: '☕',
      zona: 'Centro',
      items: [
        ItemPedido(cantidad: 2, nombre: 'Café pasado', precio: 9),
        ItemPedido(cantidad: 1, nombre: 'Queque de quinua', precio: 12),
      ],
      historial: [
        EventoPedido(
          titulo: 'Pedido entregado',
          hora: '14:05',
          origen: 'CHASQUI',
        ),
      ],
    ),
    const Pedido(
      id: '#A-2481',
      negocio: 'Pollería El Cholo',
      negocioDireccion: 'Jr. Puno 214',
      cliente: 'María Ccapa',
      clienteDireccion: 'Jr. Cajamarca 218',
      estado: EstadoPedido.entregado,
      hora: '13:22',
      repartidorId: 'rep-01',
      repartidor: 'Rubén Mamani',
      repartidorCalificacion: 4.9,
      monto: 37,
      emojiNegocio: '🍗',
      zona: 'Centro',
      items: [
        ItemPedido(cantidad: 1, nombre: 'Pollo a la brasa 1/2', precio: 28),
        ItemPedido(cantidad: 1, nombre: 'Gaseosa 1 L', precio: 9),
      ],
      historial: [
        EventoPedido(
          titulo: 'Pedido entregado',
          hora: '13:48',
          origen: 'CHASQUI',
        ),
      ],
    ),
    const Pedido(
      id: '#A-2480',
      negocio: 'Minimarket Sur',
      negocioDireccion: 'Av. Simón Bolívar 512',
      cliente: 'Julio Paredes',
      clienteDireccion: 'Jr. Ilave 77',
      estado: EstadoPedido.problema,
      hora: '13:10',
      repartidorId: 'rep-03',
      repartidor: 'Elsa Condori',
      repartidorCalificacion: 4.7,
      monto: 19,
      emojiNegocio: '🛒',
      zona: 'Salcedo',
      notaProblema: 'El cliente no responde en la dirección indicada.',
      items: [
        ItemPedido(cantidad: 1, nombre: 'Pack de agua 6 × 625 ml', precio: 12),
        ItemPedido(cantidad: 1, nombre: 'Pan de molde', precio: 7),
      ],
      historial: [
        EventoPedido(
          titulo: 'Problema reportado por el repartidor',
          hora: '13:38',
          origen: 'CHASQUI',
          enCurso: true,
        ),
      ],
    ),
    const Pedido(
      id: '#A-2479',
      negocio: 'Pizzería Nonna',
      negocioDireccion: 'Jr. Moquegua 260',
      cliente: 'Sara Flores',
      clienteDireccion: 'Jr. Puno 905',
      estado: EstadoPedido.cancelado,
      hora: '12:55',
      repartidorId: 'rep-02',
      repartidor: 'Pedro Cutipa',
      repartidorCalificacion: 4.8,
      emojiNegocio: '🍕',
      zona: 'Centro',
      items: [ItemPedido(cantidad: 1, nombre: 'Pizza americana', precio: 32)],
      historial: [
        EventoPedido(
          titulo: 'Pedido cancelado por el cliente',
          hora: '13:02',
          origen: 'app del cliente',
        ),
      ],
    ),
    const Pedido(
      id: '#A-2478',
      negocio: 'Botica Salud+',
      negocioDireccion: 'Jr. Tacna 402',
      cliente: 'Rita Choque',
      clienteDireccion: 'Jr. Bellavista 415',
      estado: EstadoPedido.buscandoRepartidor,
      hora: '14:28',
      monto: 24,
      emojiNegocio: '💊',
      zona: 'Bellavista',
      tiempoMinutos: 8,
      items: [ItemPedido(cantidad: 1, nombre: 'Ibuprofeno 400 mg', precio: 14)],
      historial: [
        EventoPedido(
          titulo: 'Sin repartidor disponible en la zona',
          hora: '14:30',
          origen: 'en curso',
          enCurso: true,
        ),
      ],
    ),
    const Pedido(
      id: '#A-2477',
      negocio: 'Chifa Titicaca',
      negocioDireccion: 'Jr. Arequipa 55',
      cliente: 'Hugo Larico',
      clienteDireccion: 'Jr. Huancané 88',
      estado: EstadoPedido.enCamino,
      hora: '13:58',
      repartidorId: 'rep-04',
      repartidor: 'Nilda Ruiz',
      repartidorCalificacion: 4.6,
      monto: 34,
      emojiNegocio: '🥡',
      zona: 'Centro',
      etaMinutos: 9,
      items: [
        ItemPedido(cantidad: 1, nombre: 'Aeropuerto de pollo', precio: 24),
      ],
      historial: [
        EventoPedido(
          titulo: 'En camino al cliente',
          hora: '14:12',
          origen: 'en curso',
          enCurso: true,
        ),
      ],
    ),
    const Pedido(
      id: '#A-2470',
      negocio: 'Chifa Titicaca',
      negocioDireccion: 'Jr. Arequipa 55',
      cliente: 'Delia Mamani',
      clienteDireccion: 'Jr. Grau 402',
      estado: EstadoPedido.problema,
      hora: '12:27',
      repartidorId: 'rep-05',
      repartidor: 'Jorge Ccama',
      repartidorCalificacion: 4.5,
      monto: 46,
      emojiNegocio: '🥡',
      zona: 'Centro',
      tiempoMinutos: 45,
      notaProblema: 'Retraso de más de 45 minutos sin resolver.',
      items: [ItemPedido(cantidad: 2, nombre: 'Tallarín saltado', precio: 23)],
      historial: [
        EventoPedido(
          titulo: 'Retraso mayor a 45 min',
          hora: '13:12',
          origen: 'sistema',
          enCurso: true,
        ),
      ],
    ),
  ];

  // ── Repartidores ───────────────────────────────────────────────────────
  late List<Repartidor> repartidores = [
    const Repartidor(
      id: 'rep-01',
      nombre: 'Rubén Mamani',
      estado: EstadoRepartidor.enCamino,
      calificacion: 4.9,
      vehiculo: 'Moto',
      placa: 'ABC-123',
      zonaActual: 'Centro · Jr. Lima',
      pedidosActivos: 1,
      gananciaHoy: 48.5,
      tiempoConectado: '3h 20m',
      dni: '4587xxxx',
      celular: '987 654 321',
      desde: 'ene. 2025',
      entregasTotales: 1284,
      nivel: 'Chasqui Oro',
      documentos: [
        DocumentoRepartidor(
          tipo: 'DNI',
          detalle: 'Subido 12 ene. 2025',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'Brevete',
          detalle: 'Vence 12 mar. 2027',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'SOAT',
          detalle: 'Vence en 21 días',
          estado: EstadoDocumento.porVencer,
        ),
        DocumentoRepartidor(
          tipo: 'T. propiedad',
          detalle: 'Esperando revisión',
          estado: EstadoDocumento.enRevision,
        ),
        DocumentoRepartidor(
          tipo: 'Foto de perfil',
          detalle: 'Subida 14 ene. 2025',
          estado: EstadoDocumento.aprobado,
        ),
      ],
      desempeno: DesempenoRepartidor(
        gananciaSemana: 412.50,
        pedidos: 47,
        aceptacion: 98,
        entregaPromedioMin: 22,
      ),
      comentarios: [
        ComentarioCliente(
          estrellas: 5,
          texto: 'Rapidísimo y muy amable',
          autor: 'María C.',
          cuando: 'hace 2 h',
        ),
        ComentarioCliente(
          estrellas: 4,
          texto: 'Todo bien, un poco tarde',
          autor: 'Carlos A.',
          cuando: 'ayer',
        ),
      ],
      zonas: [
        ZonaConexion(zona: 'Centro', porcentaje: 62),
        ZonaConexion(zona: 'Bellavista', porcentaje: 24),
        ZonaConexion(zona: 'Salcedo', porcentaje: 14),
      ],
    ),
    const Repartidor(
      id: 'rep-02',
      nombre: 'Pedro Cutipa',
      estado: EstadoRepartidor.multiPedido,
      calificacion: 4.8,
      vehiculo: 'Moto',
      placa: 'XYZ-908',
      zonaActual: 'Bellavista',
      pedidosActivos: 2,
      gananciaHoy: 62.0,
      tiempoConectado: '5h 05m',
      dni: '4712xxxx',
      celular: '987 220 118',
      desde: 'mar. 2025',
      entregasTotales: 912,
      nivel: 'Chasqui Plata',
      documentos: [
        DocumentoRepartidor(
          tipo: 'DNI',
          detalle: 'Subido 03 mar. 2025',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'Brevete',
          detalle: 'Vence 08 set. 2028',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'SOAT',
          detalle: 'Vence 20 dic. 2026',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'T. propiedad',
          detalle: 'Subida 03 mar. 2025',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'Foto de perfil',
          detalle: 'Subida 03 mar. 2025',
          estado: EstadoDocumento.aprobado,
        ),
      ],
      desempeno: DesempenoRepartidor(
        gananciaSemana: 508.00,
        pedidos: 61,
        aceptacion: 96,
        entregaPromedioMin: 25,
      ),
      comentarios: [
        ComentarioCliente(
          estrellas: 5,
          texto: 'Llegó antes de lo previsto',
          autor: 'Ana Q.',
          cuando: 'hace 5 h',
        ),
      ],
      zonas: [
        ZonaConexion(zona: 'Bellavista', porcentaje: 58),
        ZonaConexion(zona: 'Centro', porcentaje: 30),
        ZonaConexion(zona: 'Salcedo', porcentaje: 12),
      ],
    ),
    const Repartidor(
      id: 'rep-03',
      nombre: 'Elsa Condori',
      estado: EstadoRepartidor.buscando,
      calificacion: 4.7,
      vehiculo: 'Moto',
      placa: 'JKL-441',
      zonaActual: 'Salcedo',
      gananciaHoy: 31.0,
      tiempoConectado: '2h 10m',
      dni: '4890xxxx',
      celular: '987 445 902',
      desde: 'may. 2025',
      entregasTotales: 486,
      nivel: 'Chasqui Plata',
      documentos: [
        DocumentoRepartidor(
          tipo: 'DNI',
          detalle: 'Subido 11 may. 2025',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'Brevete',
          detalle: 'Vence 30 jun. 2029',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'SOAT',
          detalle: 'Vence 14 abr. 2027',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'T. propiedad',
          detalle: 'Subida 11 may. 2025',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'Foto de perfil',
          detalle: 'Subida 11 may. 2025',
          estado: EstadoDocumento.aprobado,
        ),
      ],
      desempeno: DesempenoRepartidor(
        gananciaSemana: 288.00,
        pedidos: 34,
        aceptacion: 96,
        entregaPromedioMin: 21,
      ),
      comentarios: [
        ComentarioCliente(
          estrellas: 5,
          texto: 'Muy atenta con el pedido',
          autor: 'Rosa H.',
          cuando: 'anteayer',
        ),
      ],
      zonas: [
        ZonaConexion(zona: 'Salcedo', porcentaje: 71),
        ZonaConexion(zona: 'Centro', porcentaje: 21),
        ZonaConexion(zona: 'Bellavista', porcentaje: 8),
      ],
    ),
    const Repartidor(
      id: 'rep-04',
      nombre: 'Nilda Ruiz',
      estado: EstadoRepartidor.docsPendientes,
      calificacion: 4.6,
      notaEstado: 'SOAT por vencer',
      vehiculo: 'Moto',
      dni: '4521xxxx',
      celular: '987 118 640',
      desde: 'feb. 2025',
      entregasTotales: 731,
      nivel: 'Chasqui Plata',
      documentos: [
        DocumentoRepartidor(
          tipo: 'DNI',
          detalle: 'Subido 08 feb. 2025',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'Brevete',
          detalle: 'Vence 22 nov. 2027',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'SOAT',
          detalle: 'Vence en 6 días',
          estado: EstadoDocumento.porVencer,
        ),
        DocumentoRepartidor(
          tipo: 'T. propiedad',
          detalle: 'Esperando revisión',
          estado: EstadoDocumento.enRevision,
        ),
        DocumentoRepartidor(
          tipo: 'Foto de perfil',
          detalle: 'Esperando revisión',
          estado: EstadoDocumento.enRevision,
        ),
      ],
      desempeno: DesempenoRepartidor(
        gananciaSemana: 196.50,
        pedidos: 23,
        aceptacion: 91,
        entregaPromedioMin: 27,
      ),
      zonas: [
        ZonaConexion(zona: 'Centro', porcentaje: 54),
        ZonaConexion(zona: 'Bellavista', porcentaje: 32),
        ZonaConexion(zona: 'Salcedo', porcentaje: 14),
      ],
    ),
    const Repartidor(
      id: 'rep-05',
      nombre: 'Jorge Ccama',
      estado: EstadoRepartidor.desconectado,
      calificacion: 4.5,
      vehiculo: 'Moto',
      placa: 'PQR-777',
      tiempoConectado: '0h',
      dni: '4633xxxx',
      celular: '987 902 551',
      desde: 'jun. 2025',
      entregasTotales: 318,
      nivel: 'Chasqui Bronce',
      documentos: [
        DocumentoRepartidor(
          tipo: 'DNI',
          detalle: 'Subido 02 jun. 2025',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'Brevete',
          detalle: 'Vence 17 ene. 2030',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'SOAT',
          detalle: 'Vence 05 oct. 2026',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'T. propiedad',
          detalle: 'Subida 02 jun. 2025',
          estado: EstadoDocumento.aprobado,
        ),
        DocumentoRepartidor(
          tipo: 'Foto de perfil',
          detalle: 'Subida 02 jun. 2025',
          estado: EstadoDocumento.aprobado,
        ),
      ],
      desempeno: DesempenoRepartidor(
        gananciaSemana: 142.00,
        pedidos: 17,
        aceptacion: 88,
        entregaPromedioMin: 29,
      ),
      zonas: [
        ZonaConexion(zona: 'Centro', porcentaje: 48),
        ZonaConexion(zona: 'Salcedo', porcentaje: 35),
        ZonaConexion(zona: 'Bellavista', porcentaje: 17),
      ],
    ),
  ];

  // ── Negocios ───────────────────────────────────────────────────────────
  late List<Negocio> negocios = [
    const Negocio(
      id: 'neg-01',
      nombre: 'Pollería El Cholo',
      categoria: 'Comida · Parrillas',
      direccion: 'Jr. Puno 214',
      estado: EstadoNegocio.abierto,
      horario: '11:00–23:00',
      comision: 18,
      emoji: '🍗',
      ventasHoy: 340,
      pedidosPendientes: 3,
      calificacion: 4.8,
      productos: [
        Producto(
          id: 'p-101',
          nombre: 'Pollo a la brasa entero',
          precio: 55,
          disponible: true,
          emoji: '🍗',
        ),
        Producto(
          id: 'p-102',
          nombre: 'Chaufa de pollo',
          precio: 14,
          disponible: true,
          emoji: '🍚',
        ),
        Producto(
          id: 'p-103',
          nombre: 'Anticuchos',
          precio: 18,
          disponible: false,
          emoji: '🍢',
        ),
      ],
    ),
    const Negocio(
      id: 'neg-02',
      nombre: 'Botica Salud+',
      categoria: 'Farmacia',
      direccion: 'Jr. Tacna 402',
      estado: EstadoNegocio.abierto,
      horario: '07:00–23:00',
      comision: 18,
      emoji: '💊',
      ventasHoy: 188,
      pedidosPendientes: 1,
      calificacion: 4.9,
      productos: [
        Producto(
          id: 'p-201',
          nombre: 'Paracetamol 500 mg',
          precio: 9,
          disponible: true,
          emoji: '💊',
        ),
        Producto(
          id: 'p-202',
          nombre: 'Alcohol en gel 250 ml',
          precio: 10,
          disponible: true,
          emoji: '🧴',
        ),
      ],
    ),
    const Negocio(
      id: 'neg-03',
      nombre: 'Chifa Titicaca',
      categoria: 'Comida',
      direccion: 'Jr. Arequipa 55',
      estado: EstadoNegocio.retrasos,
      horario: '11:00–22:30',
      comision: 18,
      emoji: '🥡',
      ventasHoy: 96,
      pedidosPendientes: 6,
      calificacion: 4.1,
      incidenciasAbiertas: 3,
      productos: [
        Producto(
          id: 'p-301',
          nombre: 'Arroz chaufa especial',
          precio: 22,
          disponible: true,
          emoji: '🥡',
        ),
        Producto(
          id: 'p-302',
          nombre: 'Sopa wantán',
          precio: 16,
          disponible: true,
          emoji: '🍜',
        ),
        Producto(
          id: 'p-303',
          nombre: 'Langostinos apanados',
          precio: 28,
          disponible: false,
          emoji: '🍤',
        ),
      ],
      incidencias: [
        Incidencia(
          id: 'inc-01',
          titulo: 'Retraso de 45 min · #A-2470',
          detalle: 'Hoy 13:12',
          estado: EstadoIncidencia.sinResolver,
          pedidoId: '#A-2470',
          negocioId: 'neg-03',
        ),
        Incidencia(
          id: 'inc-02',
          titulo: 'Producto incompleto · #A-2466',
          detalle: 'Hoy 12:40',
          estado: EstadoIncidencia.enRevision,
          pedidoId: '#A-2466',
          negocioId: 'neg-03',
          severidad: SeveridadIncidencia.reclamo,
        ),
        Incidencia(
          id: 'inc-03',
          titulo: 'Cobro duplicado · #A-2402',
          detalle: 'Ayer · resuelto con reembolso',
          estado: EstadoIncidencia.resuelta,
          pedidoId: '#A-2402',
          negocioId: 'neg-03',
          severidad: SeveridadIncidencia.atencion,
        ),
      ],
    ),
    const Negocio(
      id: 'neg-04',
      nombre: 'Pizzería Nonna',
      categoria: 'Comida',
      direccion: 'Jr. Moquegua 260',
      estado: EstadoNegocio.abierto,
      horario: '12:00–23:00',
      comision: 18,
      emoji: '🍕',
      ventasHoy: 265,
      pedidosPendientes: 2,
      calificacion: 4.7,
      productos: [
        Producto(
          id: 'p-401',
          nombre: 'Pizza americana familiar',
          precio: 32,
          disponible: true,
          emoji: '🍕',
        ),
        Producto(
          id: 'p-402',
          nombre: 'Lasaña de carne',
          precio: 26,
          disponible: true,
          emoji: '🍝',
        ),
      ],
    ),
    const Negocio(
      id: 'neg-05',
      nombre: 'Minimarket Sur',
      categoria: 'Bodega',
      direccion: 'Av. Simón Bolívar 512',
      estado: EstadoNegocio.abierto,
      horario: '07:00–22:00',
      comision: 12,
      emoji: '🛒',
      ventasHoy: 142,
      pedidosPendientes: 1,
      calificacion: 4.4,
      comisionPreferente: true,
      productos: [
        Producto(
          id: 'p-501',
          nombre: 'Pack de agua 6 × 625 ml',
          precio: 12,
          disponible: true,
          emoji: '💧',
        ),
        Producto(
          id: 'p-502',
          nombre: 'Pan de molde',
          precio: 7,
          disponible: true,
          emoji: '🍞',
        ),
      ],
    ),
    const Negocio(
      id: 'neg-06',
      nombre: 'Café del Lago',
      categoria: 'Cafetería',
      direccion: 'Jr. Libertad 190',
      estado: EstadoNegocio.cerrado,
      horario: '08:00–20:00',
      comision: 18,
      emoji: '☕',
      calificacion: 4.6,
      productos: [
        Producto(
          id: 'p-601',
          nombre: 'Café pasado',
          precio: 9,
          disponible: true,
          emoji: '☕',
        ),
        Producto(
          id: 'p-602',
          nombre: 'Queque de quinua',
          precio: 12,
          disponible: true,
          emoji: '🍰',
        ),
      ],
    ),
  ];

  // ── Clientes ───────────────────────────────────────────────────────────
  late List<Cliente> clientes = [
    const Cliente(
      id: 'cli-01',
      nombre: 'María Ccapa',
      celular: '987 111 222',
      pedidos: 64,
      gastoTotal: 2180,
      ultimoPedido: 'Hoy 14:18',
      estado: EstadoCliente.frecuente,
      direccion: 'Jr. Cajamarca 218',
      ticketPromedio: 34,
      registradoEn: 'ago. 2024',
    ),
    const Cliente(
      id: 'cli-02',
      nombre: 'Luis Mamani',
      celular: '987 333 444',
      pedidos: 21,
      gastoTotal: 742,
      ultimoPedido: 'Hoy 14:18',
      estado: EstadoCliente.activo,
      direccion: 'Jr. Tacna 88',
      ticketPromedio: 35,
      registradoEn: 'feb. 2025',
    ),
    const Cliente(
      id: 'cli-03',
      nombre: 'Ana Quispe',
      celular: '987 555 666',
      pedidos: 38,
      gastoTotal: 1290,
      ultimoPedido: 'Hoy 13:50',
      estado: EstadoCliente.activo,
      direccion: 'Jr. Deustua 137',
      ticketPromedio: 34,
      registradoEn: 'nov. 2024',
    ),
    const Cliente(
      id: 'cli-04',
      nombre: 'Julio Paredes',
      celular: '987 777 888',
      pedidos: 4,
      gastoTotal: 96,
      ultimoPedido: '12 jul.',
      estado: EstadoCliente.bloqueado,
      direccion: 'Jr. Ilave 77',
      ticketPromedio: 24,
      registradoEn: 'jun. 2026',
    ),
  ];

  // ── Promociones ────────────────────────────────────────────────────────
  late List<Promocion> promociones = [
    const Promocion(
      id: 'promo-01',
      titulo: 'Envío gratis > S/ 40',
      tipo: TipoPromocion.envio,
      valor: 'Gratis',
      desde: '01 jul. 2026',
      hasta: '31 jul. 2026',
      estado: EstadoPromocion.activa,
      usos: 1204,
      alcanceTexto: 'Todos los negocios · 1,204 usos',
    ),
    const Promocion(
      id: 'promo-02',
      titulo: '−15% en farmacias',
      tipo: TipoPromocion.descuento,
      valor: '15%',
      desde: '20 jul. 2026',
      hasta: '28 jul. 2026',
      estado: EstadoPromocion.terminaHoy,
      negocios: ['Botica Salud+'],
      usos: 318,
      alcanceTexto: '4 negocios · 318 usos',
    ),
  ];

  // ── Pagos ──────────────────────────────────────────────────────────────
  late ResumenPagos resumenPagos = const ResumenPagos(
    porPagarNegocios: 38420,
    porPagarRepartidores: 12860,
    comisionDelyPuno: 9140,
    pagosPendientes: 14,
    semana: 'Semana 27 jul',
  );

  late List<Liquidacion> liquidaciones = [
    const Liquidacion(
      id: 'liq-01',
      beneficiario: 'Pollería El Cholo',
      tipo: TipoBeneficiario.negocios,
      pedidos: 168,
      bruto: 6240,
      comision: 1123,
      estado: EstadoLiquidacion.pagado,
    ),
    const Liquidacion(
      id: 'liq-02',
      beneficiario: 'Pizzería Nonna',
      tipo: TipoBeneficiario.negocios,
      pedidos: 124,
      bruto: 4980,
      comision: 896,
      estado: EstadoLiquidacion.pendiente,
    ),
    const Liquidacion(
      id: 'liq-03',
      beneficiario: 'Botica Salud+',
      tipo: TipoBeneficiario.negocios,
      pedidos: 96,
      bruto: 3410,
      comision: 613,
      estado: EstadoLiquidacion.pendiente,
    ),
    const Liquidacion(
      id: 'liq-04',
      beneficiario: 'Minimarket Sur',
      tipo: TipoBeneficiario.negocios,
      pedidos: 72,
      bruto: 1880,
      comision: 226,
      estado: EstadoLiquidacion.observado,
    ),
    const Liquidacion(
      id: 'liq-05',
      beneficiario: 'Rubén Mamani',
      tipo: TipoBeneficiario.repartidores,
      pedidos: 47,
      bruto: 516,
      comision: 103,
      estado: EstadoLiquidacion.pagado,
    ),
    const Liquidacion(
      id: 'liq-06',
      beneficiario: 'Pedro Cutipa',
      tipo: TipoBeneficiario.repartidores,
      pedidos: 61,
      bruto: 635,
      comision: 127,
      estado: EstadoLiquidacion.pendiente,
    ),
    const Liquidacion(
      id: 'liq-07',
      beneficiario: 'Elsa Condori',
      tipo: TipoBeneficiario.repartidores,
      pedidos: 34,
      bruto: 360,
      comision: 72,
      estado: EstadoLiquidacion.pendiente,
    ),
    const Liquidacion(
      id: 'liq-08',
      beneficiario: 'Pollería El Cholo',
      tipo: TipoBeneficiario.historico,
      pedidos: 154,
      bruto: 5820,
      comision: 1047,
      estado: EstadoLiquidacion.pagado,
      periodo: 'Semana 20 jul',
    ),
    const Liquidacion(
      id: 'liq-09',
      beneficiario: 'Chifa Titicaca',
      tipo: TipoBeneficiario.historico,
      pedidos: 88,
      bruto: 3120,
      comision: 561,
      estado: EstadoLiquidacion.pagado,
      periodo: 'Semana 20 jul',
    ),
  ];

  // ── Configuración ──────────────────────────────────────────────────────
  late ConfiguracionOperativa configuracion = const ConfiguracionOperativa(
    costosEnvio: [
      ParametroTarifa(
        clave: 'tarifa_base',
        titulo: 'Tarifa base',
        descripcion: 'Primeros 2 km',
        valor: 5,
        unidad: 'S/',
      ),
      ParametroTarifa(
        clave: 'km_adicional',
        titulo: 'Por km adicional',
        descripcion: 'A partir del km 3',
        valor: 1.20,
        unidad: 'S/',
      ),
      ParametroTarifa(
        clave: 'recargo_pico',
        titulo: 'Recargo hora pico',
        descripcion: '12:00–14:00 y 19:00–21:00',
        valor: 1.50,
        unidad: 'S/',
      ),
    ],
    comisiones: [
      ParametroTarifa(
        clave: 'comision_estandar',
        titulo: 'Comisión estándar',
        descripcion: 'Sobre el total del pedido',
        valor: 18,
        unidad: '%',
      ),
      ParametroTarifa(
        clave: 'comision_bodegas',
        titulo: 'Comisión bodegas',
        descripcion: 'Categoría con margen bajo',
        valor: 12,
        unidad: '%',
      ),
      ParametroTarifa(
        clave: 'pago_repartidor',
        titulo: 'Pago al repartidor',
        descripcion: 'Del costo de envío',
        valor: 80,
        unidad: '%',
      ),
    ],
    equipo: [
      MiembroEquipo(
        id: 'eq-01',
        nombre: 'Julia Torres',
        correo: 'julia@delypuno.pe',
        rol: RolEquipo.adminTotal,
      ),
      MiembroEquipo(
        id: 'eq-02',
        nombre: 'Marco Vilca',
        correo: 'marco@delypuno.pe',
        rol: RolEquipo.operaciones,
      ),
      MiembroEquipo(
        id: 'eq-03',
        nombre: 'Sofía Ramos',
        correo: 'sofia@delypuno.pe',
        rol: RolEquipo.soporte,
      ),
    ],
    ajustes: [
      AjusteOperativo(
        clave: 'asignacion_automatica',
        titulo: 'Asignación automática',
        descripcion: 'Elige el repartidor más cercano',
        activo: true,
      ),
      AjusteOperativo(
        clave: 'multi_pedido',
        titulo: 'Multi-pedido',
        descripcion: 'Hasta 3 pedidos por repartidor',
        activo: true,
      ),
      AjusteOperativo(
        clave: 'heatmap',
        titulo: 'Heatmap para repartidores',
        descripcion: 'Visible en CHASQUI',
        activo: true,
      ),
      AjusteOperativo(
        clave: 'mantenimiento',
        titulo: 'Modo mantenimiento',
        descripcion: 'Detiene nuevos pedidos',
        activo: false,
      ),
    ],
  );

  // ── Reportes ───────────────────────────────────────────────────────────
  final ReporteMensual reporte = const ReporteMensual(
    periodo: 'Julio 2026',
    metricas: [
      MetricaReporte(
        titulo: 'Ingresos del mes',
        valor: 'S/ 184,300',
        variacion: '+18% vs. junio',
      ),
      MetricaReporte(
        titulo: 'Pedidos completados',
        valor: '5,428',
        variacion: '+11% vs. junio',
      ),
      MetricaReporte(
        titulo: 'Tiempo medio de entrega',
        valor: '24 min',
        variacion: '+2 min vs. junio',
        neutral: true,
      ),
      MetricaReporte(
        titulo: 'Tasa de cancelación',
        valor: '3.2%',
        variacion: '−0.6 pts vs. junio',
      ),
    ],
    ingresosPorSemana: [
      PuntoSerie(etiqueta: 'Sem 1', valor: 37806),
      PuntoSerie(etiqueta: 'Sem 2', valor: 46582),
      PuntoSerie(etiqueta: 'Sem 3', valor: 42532),
      PuntoSerie(etiqueta: 'Sem 4', valor: 57380, destacado: true),
    ],
    categorias: [
      ParticipacionCategoria(categoria: 'Comida', porcentaje: 62),
      ParticipacionCategoria(categoria: 'Farmacia', porcentaje: 18),
      ParticipacionCategoria(categoria: 'Bodega', porcentaje: 14),
      ParticipacionCategoria(categoria: 'Otros', porcentaje: 6),
    ],
    topNegocios: [
      FilaTopNegocio(
        posicion: 1,
        negocio: 'Pollería El Cholo',
        pedidos: 642,
        ventas: 24180,
        comision: 4352,
      ),
      FilaTopNegocio(
        posicion: 2,
        negocio: 'Pizzería Nonna',
        pedidos: 488,
        ventas: 19640,
        comision: 3535,
      ),
      FilaTopNegocio(
        posicion: 3,
        negocio: 'Botica Salud+',
        pedidos: 402,
        ventas: 14220,
        comision: 2560,
      ),
    ],
  );

  // ── Dashboard ──────────────────────────────────────────────────────────
  final ResumenOperativo resumen = const ResumenOperativo(
    pedidosActivos: 42,
    pedidosPreparando: 18,
    pedidosEnCamino: 24,
    ventasDia: 8420,
    variacionVentas: '+12% vs. ayer · mes S/ 184,300',
    ventasMes: 184300,
    repartidoresActivos: 31,
    repartidoresTotales: 58,
    repartidoresConPedido: 19,
    repartidoresBuscando: 12,
    negociosAbiertos: 76,
    negociosTotales: 94,
    clientesConectados: 312,
    documentosPorVerificar: 4,
    negociosConIncidencias: 3,
    ventasSemanaAcumulado: 46180,
    ventasSemana: [
      PuntoSerie(etiqueta: 'Lun', valor: 5186),
      PuntoSerie(etiqueta: 'Mar', valor: 6544),
      PuntoSerie(etiqueta: 'Mié', valor: 5680),
      PuntoSerie(etiqueta: 'Jue', valor: 7902),
      PuntoSerie(etiqueta: 'Vie', valor: 9261, destacado: true),
      PuntoSerie(etiqueta: 'Sáb', valor: 7285),
      PuntoSerie(etiqueta: 'Dom', valor: 4322),
    ],
    horaPico: '13:00 – 14:00',
    pedidosPorHora: [
      PuntoSerie(etiqueta: '8h', valor: 22),
      PuntoSerie(etiqueta: '10h', valor: 32),
      PuntoSerie(etiqueta: '12h', valor: 54),
      PuntoSerie(etiqueta: '13h', valor: 88),
      PuntoSerie(etiqueta: '14h', valor: 132, destacado: true),
      PuntoSerie(etiqueta: '17h', valor: 96),
      PuntoSerie(etiqueta: '20h', valor: 62),
      PuntoSerie(etiqueta: '23h', valor: 44),
    ],
  );

  /// Incidencias recientes que muestra el dashboard.
  late List<Incidencia> incidenciasRecientes = [
    const Incidencia(
      id: 'inc-d1',
      titulo: 'Retraso > 45 min · #A-2470',
      detalle: 'Chifa Titicaca · hace 12 min',
      estado: EstadoIncidencia.sinResolver,
      pedidoId: '#A-2470',
      negocioId: 'neg-03',
    ),
    const Incidencia(
      id: 'inc-d2',
      titulo: 'Sin repartidor 8 min · #A-2478',
      detalle: 'Zona Bellavista · hace 4 min',
      estado: EstadoIncidencia.sinResolver,
      pedidoId: '#A-2478',
      severidad: SeveridadIncidencia.atencion,
    ),
    const Incidencia(
      id: 'inc-d3',
      titulo: 'Reclamo de cliente · #A-2466',
      detalle: 'Producto incompleto · hace 26 min',
      estado: EstadoIncidencia.enRevision,
      pedidoId: '#A-2466',
      negocioId: 'neg-03',
      severidad: SeveridadIncidencia.reclamo,
    ),
  ];

  /// Historial de reasignaciones que muestra el frame 06.
  late List<String> historialReasignaciones = [
    'Pedro Cutipa ← Nilda Ruiz|14:26 · Julia Torres · «moto averiada»',
    'Asignación automática|14:20 · sistema',
  ];

  /// Total de pedidos del día que muestra el encabezado del frame 02.
  static const int pedidosHoy = 186;

  /// Zonas de reparto disponibles en el filtro del frame 04.
  static const List<String> zonas = [
    'Centro',
    'Bellavista',
    'Salcedo',
    'Chejoña',
    'Alto Puno',
  ];

  /// Distancia de cada repartidor al negocio, y minutos estimados, tal como
  /// los fija el frame 06.
  ///
  /// Con Firebase saldrán de la geolocalización en vivo de CHASQUI; aquí son
  /// fijos para que el centro de reasignación muestre siempre las mismas
  /// cifras del diseño.
  static const Map<String, ({double km, int minutos, int aceptacion})>
  distanciasReasignacion = {
    'rep-01': (km: 1.2, minutos: 7, aceptacion: 98),
    'rep-02': (km: 1.8, minutos: 9, aceptacion: 96),
    'rep-03': (km: 0.6, minutos: 4, aceptacion: 96),
    'rep-04': (km: 2.1, minutos: 11, aceptacion: 91),
    'rep-05': (km: 2.9, minutos: 15, aceptacion: 88),
  };

  /// Motivos de reasignación del desplegable del frame 06.
  static const List<String> motivosReasignacion = [
    'Moto averiada',
    'Repartidor no responde',
    'Repartidor sobrecargado',
    'Cliente cambió la dirección',
    'Retraso acumulado',
    'Solicitud del negocio',
  ];
}
