
#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>

#include <stdio.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <algorithm>
#include <time.h>

//-----------------------------------------------------------------------------

const int MaxStrLen = 256;

long int GetFileSizeFromStat( FILE* file );
long int ReadAllFile        ( FILE* file, char** str );

int GetRandNum( int min, int max );

void CrackCOM( FILE* file_out, char* buffer, int file_size );

//-----------------------------------------------------------------------------

int main()
{
    srand( time( NULL ) );
    
    int window_width  = 1600;
    int window_height = 1000; 
    
    sf::RenderWindow window( sf::VideoMode( window_width, window_height ), "CrackPook!" );
    window.setFramerateLimit(1);

    sf::Music music;
    music.openFromFile( "music.ogg" );
    music.play();

    sf::RectangleShape progress_bar( sf::Vector2f( 0, 50 ) );

    progress_bar.setPosition ( 0, window_height - 50 );
    progress_bar.setFillColor( sf::Color::Green );

    sf::Image mario_image;
    mario_image.loadFromFile( "mario.png" );

    sf::Texture mario_texture;
    mario_texture.loadFromImage( mario_image );

    sf::Vector2f mario_size( 170, 220 );
    sf::RectangleShape mario( mario_size );
    mario.setTexture ( &mario_texture );
    mario.setPosition( 0, window_height - mario_size.y - 50 );

    int x = 0;
    
    bool is_progress_bar_right = true;

    while( window.isOpen() )
    {
        sf::Event event;
        while( window.pollEvent(event) )
        {
            if( event.type == sf::Event::Closed ) window.close();
        }
        
        if( is_progress_bar_right )
        {
            if( x < window_width )
            {
                x += 100;
                if( x > window_width ) x = window_width; 
            }
            else
            {
                is_progress_bar_right = false;
            }
        }
        else
        {
            if( x > 0 )
            {
                x -= 100;
                if( x < 0 ) x = 0; 
            }
            else
            {
                is_progress_bar_right = true;
            }
        }

        progress_bar.setSize( sf::Vector2f( x, progress_bar.getSize().y ) );

        mario.setPosition( GetRandNum( 0, window_width  - mario_size.x ), 
                           GetRandNum( 0, window_height - mario_size.y - 50 ) );

        window.clear( sf::Color::White );
        window.draw( progress_bar );
        window.draw( mario );
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

int GetRandNum( int min, int max )
{
    return rand() % ( max - min + 1 )+ min;
}  

//-----------------------------------------------------------------------------