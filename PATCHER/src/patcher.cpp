
#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>

#include <stdio.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <algorithm>

//-----------------------------------------------------------------------------

const int MaxStrLen = 256;

long int GetFileSizeFromStat( FILE* file );
long int ReadAllFile        ( FILE* file, char** str );

void CrackCOM( FILE* file_out, char* buffer, int file_size );

//-----------------------------------------------------------------------------

int main()
{
    int window_width  = 1000;
    int window_height = 600; 
    
    sf::RenderWindow window( sf::VideoMode( window_width, window_height ), "CrackPook!" );

    sf::CircleShape shape(100.f);
    shape.setFillColor(sf::Color::Green);

    sf::Music music;
    music.openFromFile( "music.ogg" );
    music.play();

    while( window.isOpen() )
    {
        sf::Event event;
        while( window.pollEvent(event) )
        {
            if( event.type == sf::Event::Closed ) window.close();
        }

        

        window.clear();
        window.display();
    }

    char  com_file_name[MaxStrLen] = "../EGORIKK/MAIN.COM";
    FILE* com_file = fopen( com_file_name, "rb" );

    char* buffer = "";
    int   file_size = ReadAllFile( com_file, &buffer ); 

    char  new_com_file_name[MaxStrLen] = "MAIN_NEW.COM";
    FILE* new_com_file = fopen( new_com_file_name, "wb" );

    CrackCOM( new_com_file, buffer, file_size );

    fclose(     com_file );
    fclose( new_com_file );

    return 0;
}

//-----------------------------------------------------------------------------

void CrackCOM( FILE* file_out, char* buffer, int file_size )
{
    char new_ops[] = { char(0xBE), char(0x34), char(0x01),
                       char(0xFF), char(0xE6) };

    memcpy( buffer + 0x20, new_ops, sizeof( new_ops ) );
    
    fwrite( buffer, file_size, sizeof( *buffer ), file_out );
}

//-----------------------------------------------------------------------------

long int GetFileSizeFromStat( FILE* file ) 
{
    //{ ASSERT
    assert( file != NULL );
    //}

    struct stat fileInfo = {};

    fstat( fileno( file ), &fileInfo );

    long int fileSize = fileInfo.st_size;

    return fileSize;
} 

//-----------------------------------------------------------------------------

long int ReadAllFile( FILE* file, char** str )
{
    // ASSERT
    assert (file != NULL);
    assert (str  != NULL);
    //

    long int fileSize = GetFileSizeFromStat( file );
    
    *str = ( char* )calloc( sizeof( char ), fileSize + 1 );

    long int rightRead = fread( *str, sizeof( char ), fileSize, file );

    if( rightRead < fileSize )
        realloc( str, sizeof( char ) * ( rightRead + 1 ) ); // Windows specific, \r remove

    (*str)[rightRead] = '\0';

    return rightRead;
}

//-----------------------------------------------------------------------------