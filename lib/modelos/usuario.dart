class Usuario {
    final String id; //Se definen las propiedades de la clase Usuario
    final String nombre;
    final int edad;
    final String correo;
    final String rol;
    final String? fotoPerfil;
    final DateTime fechaCreacion;

    Usuario({ //Se crea una instancia de usuario como un constructor de la clase Usuario
        required this.id,
        required this.nombre,
        required this.edad,
        required this.correo,
        required this.rol,
        this.fotoPerfil,
        required this.fechaCreacion,
    });

    factory Usuario.fromJson(Map<String, dynamic> json){ //Se crea un metodo factory para crear una instancia de Usuario a partir de un mapa JSON 
        return Usuario(
            id: json['id'],
            nombre: json['nombre'],
            edad: json['edad'],
            correo: json['correo'],
            rol: json['rol'] ?? 'empleado', //Se asigna un valor por defecto a la propiedad rol en caso de que no se encuentre en el JSON
            fotoPerfil: json['fotoPerfil'],
            fechaCreacion: DateTime.parse(json['fechaCreacion']),
        );
    }

    //Se crea un metodo toJson para convertir una instancia de Usuario a un mapa JSON
    Map<String, dynamic> toJson(){
        return{
            'id': id,
            'nombre': nombre,
            'edad': edad,
            'correo': correo,
            'rol': rol,
            'fotoPerfil': fotoPerfil,
            'fechaCreacion': fechaCreacion.toIso8601String(), //Se convierte la fecha de creación a una cadena en formato ISO 8601
        };
    }

    Usuario copyWith({ //Se crea un metodo copyWith para crear una copia de una instancia de Usuario con propiedades modificadas
        String? nombre,
        int? edad,
        String? correo,
        String? rol,
        String? fotoPerfil,
    }){
        return Usuario(
            id: id,
            nombre: nombre ?? this.nombre,
            edad: edad ?? this.edad,
            correo: correo ?? this.correo,
            rol: rol ?? this.rol,
            fotoPerfil: fotoPerfil ?? this.fotoPerfil,//Se asigna un valor por defecto a la propiedad rol en caso de que no se encuentre en el JSON
            fechaCreacion: fechaCreacion,
        );
    }
}